USE [ExaminationSystemDB]
GO

-- =====================================================================
--  stp_AddExamQuestion  (v2 - Improved)
--
--  الإصلاحات والتحسينات على النسخة السابقة:
--  [FIX  #1] إضافة isActive = 1 في الـ Instructor JOIN (كان ناقص)
--  [FIX  #2] إضافة StartTime > GETDATE() check - منع التعديل على امتحان
--             انتهى أو بدأ فعلاً (الـ Time Lock وحده مش كافي)
--  [NEW  #3] @SkipExisting BIT = 0 → لو 1 يتجاهل الأسئلة الموجودة
--             بالفعل ويضيف الباقيين بدل ما يفشل بالكامل
--  [NEW  #4] @AddedCount INT OUTPUT → يرجع عدد الأسئلة اللي اتضافت فعلاً
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_AddExamQuestion
    @ExamId        INT,
    @QuestionIds   NVARCHAR(MAX),
    @SkipExisting  BIT = 0,              -- 0 = error on duplicate | 1 = skip silently
    @AddedCount    INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check - Instructors النشطين فقط
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I
               ON UA.UserId  = I.UserId
              AND I.isActive = 1              -- [FIX #1] كانت ناقصة
        WHERE  UA.UserName = SUSER_NAME();

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied: Only active instructors can add questions to exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: التحقق من وجود الـ Exam وحالته
        -- ==============================================================
        DECLARE @ExamIsDeleted    BIT,
                @ExamStartTime    DATETIME,
                @CourseInstanceId INT;

        SELECT @ExamIsDeleted    = IsDeleted,
               @ExamStartTime    = StartTime,
               @CourseInstanceId = CourseInstanceId
        FROM   [exams].Exam
        WHERE  ExamId = @ExamId;

        IF @ExamIsDeleted IS NULL
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @ExamIsDeleted = 1
        BEGIN
            RAISERROR('Cannot add questions to a deleted exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- [FIX #2] منع التعديل على امتحان بدأ فعلاً (مش بس الـ Lock)
        IF @ExamStartTime <= GETDATE()
        BEGIN
            RAISERROR('Cannot add questions: the exam has already started or passed.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership
        -- ==============================================================
        DECLARE @CourseId INT;

        SELECT @CourseId = CI.CourseId
        FROM   [Courses].CourseInstance CI
        WHERE  CI.CourseInstanceId = @CourseInstanceId
          AND  CI.InstructorId     = @CurrentInsId;

        IF @CourseId IS NULL
        BEGIN
            RAISERROR('Access Denied: You can only add questions to your own exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Time Lock – منع الإضافة قبل الامتحان بساعة
        -- ==============================================================
        IF GETDATE() >= DATEADD(HOUR, -1, @ExamStartTime)
        BEGIN
            RAISERROR('Cannot modify exam questions: the exam is locked 1 hour before it starts.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: منع الإضافة لو طلاب بدأوا
        -- ==============================================================
        IF EXISTS (SELECT 1 FROM [exams].Student_Answer      WHERE ExamId = @ExamId)
        OR EXISTS (SELECT 1 FROM [exams].Student_Exam_Result WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Cannot modify exam questions: one or more students have already started this exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: Validate QuestionIds Input
        -- ==============================================================
        IF @QuestionIds IS NULL OR TRIM(@QuestionIds) = ''
        BEGIN
            RAISERROR('QuestionIds must be provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: Parse and Deduplicate Input IDs
        -- ==============================================================
        DECLARE @QRaw      TABLE (QuestionId INT);
        DECLARE @QDistinct TABLE (QuestionId INT);

        INSERT INTO @QRaw (QuestionId)
        SELECT CAST(TRIM(value) AS INT)
        FROM   STRING_SPLIT(@QuestionIds, ',')
        WHERE  TRIM(value) != '';

        INSERT INTO @QDistinct (QuestionId)
        SELECT DISTINCT QuestionId FROM @QRaw;

        DECLARE @RawCount      INT = (SELECT COUNT(*) FROM @QRaw);
        DECLARE @DistinctCount INT = (SELECT COUNT(*) FROM @QDistinct);

        IF @DistinctCount = 0
        BEGIN
            RAISERROR('No valid question IDs provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @RawCount > @DistinctCount
            PRINT 'Note: ' + CAST(@RawCount - @DistinctCount AS NVARCHAR(10))
                + ' duplicate question ID(s) in input were ignored. '
                + CAST(@DistinctCount AS NVARCHAR(10))
                + ' unique question(s) will be processed.';

        -- ==============================================================
        -- STEP 8: التحقق من أن جميع الأسئلة تنتمي لنفس الـ Course
        -- ==============================================================
        DECLARE @InvalidCount INT;

        SELECT @InvalidCount = COUNT(*)
        FROM   @QDistinct QT
        LEFT JOIN [exams].Question Q
               ON Q.QuestionId = QT.QuestionId
              AND Q.CourseId   = @CourseId
              AND Q.IsDeleted  = 0
        WHERE  Q.QuestionId IS NULL;

        IF @InvalidCount > 0
        BEGIN
            RAISERROR(
                '%d question(s) do not belong to this exam''s course or are deleted.',
                16, 1, @InvalidCount
            );
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 9: التحقق من عدم وجود الأسئلة مسبقاً في الـ Exam
        --         [NEW #3] لو @SkipExisting = 1 → print warning وكمّل
        -- ==============================================================
        DECLARE @AlreadyExists INT;

        SELECT @AlreadyExists = COUNT(*)
        FROM   @QDistinct QT
        INNER JOIN [exams].ExamQuestion EQ
               ON EQ.QuestionId = QT.QuestionId
              AND EQ.ExamId     = @ExamId;

        IF @AlreadyExists > 0
        BEGIN
            IF @SkipExisting = 0
            BEGIN
                RAISERROR(
                    '%d question(s) are already assigned to this exam. Use @SkipExisting = 1 to skip them.',
                    16, 1, @AlreadyExists
                );
                ROLLBACK; RETURN;
            END
            ELSE
                PRINT 'Note: ' + CAST(@AlreadyExists AS NVARCHAR(10))
                    + ' already-assigned question(s) were skipped.';
        END

        -- ==============================================================
        -- STEP 10: Insert (استثناء الموجودين لو SkipExisting = 1)
        -- ==============================================================
        INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
        SELECT @ExamId, QT.QuestionId
        FROM   @QDistinct QT
        WHERE  NOT EXISTS (
            SELECT 1 FROM [exams].ExamQuestion EQ
            WHERE  EQ.ExamId     = @ExamId
              AND  EQ.QuestionId = QT.QuestionId
        );

        DECLARE @ActualAdded INT = @@ROWCOUNT;
        SET @AddedCount = @ActualAdded;       -- [NEW #4] Output Parameter

        COMMIT TRANSACTION;
        PRINT 'Questions added successfully to Exam ID = ' + CAST(@ExamId AS NVARCHAR(10))
            + ' | Questions added: ' + CAST(@ActualAdded AS NVARCHAR(10));

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: one or more questions are already assigned to this exam.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_UpdateExamQuestion  (v2 - Improved)
--
--  الإصلاحات والتحسينات على النسخة السابقة:
--  [FIX #1] إضافة isActive = 1 في الـ Instructor JOIN
--  [FIX #2] إضافة StartTime > GETDATE() check
--  [NEW #3] دعم تبديل أسئلة متعددة دفعة واحدة عبر:
--           @SwapList NVARCHAR(MAX) = 'OldId:NewId, OldId:NewId, ...'
--           مع الإبقاء على @OldQuestionId / @NewQuestionId للتوافق
--           مع النسخة القديمة (Single-swap mode)
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_UpdateExamQuestion
    @ExamId        INT,
    @OldQuestionId INT           = NULL,   -- Single swap mode
    @NewQuestionId INT           = NULL,   -- Single swap mode
    @SwapList      NVARCHAR(MAX) = NULL    -- Multi swap: 'OldId:NewId, OldId:NewId'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check - Instructors النشطين فقط
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I
               ON UA.UserId  = I.UserId
              AND I.isActive = 1              -- [FIX #1]
        WHERE  UA.UserName = SUSER_NAME();

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied: Only active instructors can update exam questions.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: التحقق من Input Mode
        -- ==============================================================
        -- لازم يبعت إما Single أو SwapList مش الاتنين مع بعض
        IF (@OldQuestionId IS NOT NULL OR @NewQuestionId IS NOT NULL)
           AND @SwapList IS NOT NULL
        BEGIN
            RAISERROR(
                'Provide either (@OldQuestionId + @NewQuestionId) OR @SwapList, not both.',
                16, 1
            );
            ROLLBACK; RETURN;
        END

        IF @OldQuestionId IS NULL AND @NewQuestionId IS NULL AND
           (@SwapList IS NULL OR TRIM(@SwapList) = '')
        BEGIN
            RAISERROR(
                'Must provide either (@OldQuestionId + @NewQuestionId) or @SwapList.',
                16, 1
            );
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: التحقق من وجود الـ Exam وحالته
        -- ==============================================================
        DECLARE @ExamIsDeleted    BIT,
                @ExamStartTime    DATETIME,
                @CourseInstanceId INT;

        SELECT @ExamIsDeleted    = IsDeleted,
               @ExamStartTime    = StartTime,
               @CourseInstanceId = CourseInstanceId
        FROM   [exams].Exam
        WHERE  ExamId = @ExamId;

        IF @ExamIsDeleted IS NULL
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @ExamIsDeleted = 1
        BEGIN
            RAISERROR('Cannot update questions of a deleted exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- [FIX #2]
        IF @ExamStartTime <= GETDATE()
        BEGIN
            RAISERROR('Cannot update questions: the exam has already started or passed.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Instructor Ownership
        -- ==============================================================
        DECLARE @CourseId INT;

        SELECT @CourseId = CI.CourseId
        FROM   [Courses].CourseInstance CI
        WHERE  CI.CourseInstanceId = @CourseInstanceId
          AND  CI.InstructorId     = @CurrentInsId;

        IF @CourseId IS NULL
        BEGIN
            RAISERROR('Access Denied: You can only update questions for your own exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: Time Lock
        -- ==============================================================
        IF GETDATE() >= DATEADD(HOUR, -1, @ExamStartTime)
        BEGIN
            RAISERROR('Cannot modify exam questions: the exam is locked 1 hour before it starts.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: منع التعديل لو طلاب بدأوا
        -- ==============================================================
        IF EXISTS (SELECT 1 FROM [exams].Student_Answer      WHERE ExamId = @ExamId)
        OR EXISTS (SELECT 1 FROM [exams].Student_Exam_Result WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Cannot modify exam questions: one or more students have already started this exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: بناء جدول الـ Swaps
        -- ==============================================================
        DECLARE @Swaps TABLE (OldId INT, NewId INT);

        IF @SwapList IS NOT NULL AND TRIM(@SwapList) != ''
        BEGIN
            -- [NEW #3] Parse 'OldId:NewId, OldId:NewId' format
            INSERT INTO @Swaps (OldId, NewId)
            SELECT
                CAST(TRIM(LEFT(TRIM(value), CHARINDEX(':', TRIM(value)) - 1))  AS INT),
                CAST(TRIM(RIGHT(TRIM(value), LEN(TRIM(value)) - CHARINDEX(':', TRIM(value)))) AS INT)
            FROM STRING_SPLIT(@SwapList, ',')
            WHERE TRIM(value) != ''
              AND CHARINDEX(':', TRIM(value)) > 0;

            IF (SELECT COUNT(*) FROM @Swaps) = 0
            BEGIN
                RAISERROR('SwapList format is invalid. Use: ''OldId:NewId, OldId:NewId''', 16, 1);
                ROLLBACK; RETURN;
            END
        END
        ELSE
        BEGIN
            -- Single swap mode
            IF @OldQuestionId IS NULL OR @NewQuestionId IS NULL
            BEGIN
                RAISERROR('Both @OldQuestionId and @NewQuestionId must be provided for single swap.', 16, 1);
                ROLLBACK; RETURN;
            END
            INSERT INTO @Swaps (OldId, NewId) VALUES (@OldQuestionId, @NewQuestionId);
        END

        -- ==============================================================
        -- STEP 8: Validate Swaps
        -- ==============================================================

        -- منع Old = New
        IF EXISTS (SELECT 1 FROM @Swaps WHERE OldId = NewId)
        BEGIN
            RAISERROR('One or more swaps have the same Old and New question ID. No update needed.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- منع تكرار نفس الـ OldId في القائمة
        IF EXISTS (
            SELECT OldId FROM @Swaps GROUP BY OldId HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR('SwapList contains duplicate OldId values.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- التحقق من وجود جميع OldIds في الـ Exam
        DECLARE @OldNotFound INT;

        SELECT @OldNotFound = COUNT(*)
        FROM   @Swaps S
        LEFT JOIN [exams].ExamQuestion EQ
               ON EQ.QuestionId = S.OldId
              AND EQ.ExamId     = @ExamId
        WHERE  EQ.QuestionId IS NULL;

        IF @OldNotFound > 0
        BEGIN
            RAISERROR('%d old question(s) are not assigned to this exam.', 16, 1, @OldNotFound);
            ROLLBACK; RETURN;
        END

        -- التحقق من أن جميع NewIds تنتمي للـ Course وغير محذوفة
        DECLARE @NewInvalid INT;

        SELECT @NewInvalid = COUNT(*)
        FROM   @Swaps S
        LEFT JOIN [exams].Question Q
               ON Q.QuestionId = S.NewId
              AND Q.CourseId   = @CourseId
              AND Q.IsDeleted  = 0
        WHERE  Q.QuestionId IS NULL;

        IF @NewInvalid > 0
        BEGIN
            RAISERROR(
                '%d new question(s) do not belong to this exam''s course or are deleted.',
                16, 1, @NewInvalid
            );
            ROLLBACK; RETURN;
        END

        -- منع استبدال بسؤال موجود بالفعل في الـ Exam (وليس ضمن الـ OldIds)
        DECLARE @NewAlreadyInExam INT;

        SELECT @NewAlreadyInExam = COUNT(*)
        FROM   @Swaps S
        INNER JOIN [exams].ExamQuestion EQ
               ON EQ.QuestionId = S.NewId
              AND EQ.ExamId     = @ExamId
        WHERE  S.NewId NOT IN (SELECT OldId FROM @Swaps);

        IF @NewAlreadyInExam > 0
        BEGIN
            RAISERROR(
                '%d new question(s) are already assigned to this exam.',
                16, 1, @NewAlreadyInExam
            );
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 9: Perform Updates
        -- ==============================================================
        UPDATE EQ
        SET    EQ.QuestionId = S.NewId
        FROM   [exams].ExamQuestion EQ
        INNER JOIN @Swaps S ON EQ.QuestionId = S.OldId
        WHERE  EQ.ExamId = @ExamId;

        DECLARE @UpdatedCount INT = @@ROWCOUNT;

        COMMIT TRANSACTION;
        PRINT 'Exam question(s) updated successfully. ExamId = ' + CAST(@ExamId AS NVARCHAR(10))
            + ' | Swaps applied: ' + CAST(@UpdatedCount AS NVARCHAR(10));

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: one or more new questions are already assigned to this exam.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_DeleteExamQuestion  (v2 - Improved)
--
--  الإصلاحات والتحسينات على النسخة السابقة:
--  [FIX #1] إضافة isActive = 1 في الـ Instructor JOIN
--  [FIX #2] إضافة StartTime > GETDATE() check
--  [NEW #3] @SkipNotFound BIT = 0 → لو 1 يتجاهل الأسئلة الغير موجودة
--            ويحذف الباقيين بدل ما يفشل بالكامل
--  [NEW #4] @RemovedCount INT OUTPUT → يرجع عدد الأسئلة المحذوفة فعلاً
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_DeleteExamQuestion
    @ExamId        INT,
    @QuestionIds   NVARCHAR(MAX),
    @SkipNotFound  BIT = 0,              -- 0 = error | 1 = skip silently
    @RemovedCount  INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check - Instructors النشطين فقط
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I
               ON UA.UserId  = I.UserId
              AND I.isActive = 1              -- [FIX #1]
        WHERE  UA.UserName = SUSER_NAME();

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied: Only active instructors can remove questions from exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: التحقق من وجود الـ Exam وحالته
        -- ==============================================================
        DECLARE @ExamIsDeleted    BIT,
                @ExamStartTime    DATETIME,
                @CourseInstanceId INT;

        SELECT @ExamIsDeleted    = IsDeleted,
               @ExamStartTime    = StartTime,
               @CourseInstanceId = CourseInstanceId
        FROM   [exams].Exam
        WHERE  ExamId = @ExamId;

        IF @ExamIsDeleted IS NULL
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @ExamIsDeleted = 1
        BEGIN
            RAISERROR('Cannot remove questions from a deleted exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- [FIX #2]
        IF @ExamStartTime <= GETDATE()
        BEGIN
            RAISERROR('Cannot remove questions: the exam has already started or passed.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership
        -- ==============================================================
        DECLARE @CourseId INT;

        SELECT @CourseId = CI.CourseId
        FROM   [Courses].CourseInstance CI
        WHERE  CI.CourseInstanceId = @CourseInstanceId
          AND  CI.InstructorId     = @CurrentInsId;

        IF @CourseId IS NULL
        BEGIN
            RAISERROR('Access Denied: You can only remove questions from your own exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Time Lock
        -- ==============================================================
        IF GETDATE() >= DATEADD(HOUR, -1, @ExamStartTime)
        BEGIN
            RAISERROR('Cannot modify exam questions: the exam is locked 1 hour before it starts.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: منع الحذف لو طلاب بدأوا
        -- ==============================================================
        IF EXISTS (SELECT 1 FROM [exams].Student_Answer      WHERE ExamId = @ExamId)
        OR EXISTS (SELECT 1 FROM [exams].Student_Exam_Result WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Cannot modify exam questions: one or more students have already started this exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: Validate QuestionIds Input
        -- ==============================================================
        IF @QuestionIds IS NULL OR TRIM(@QuestionIds) = ''
        BEGIN
            RAISERROR('QuestionIds must be provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: Parse and Deduplicate Input IDs
        -- ==============================================================
        DECLARE @QDistinct TABLE (QuestionId INT);

        INSERT INTO @QDistinct (QuestionId)
        SELECT DISTINCT CAST(TRIM(value) AS INT)
        FROM   STRING_SPLIT(@QuestionIds, ',')
        WHERE  TRIM(value) != '';

        DECLARE @ToDeleteCount INT = (SELECT COUNT(*) FROM @QDistinct);

        IF @ToDeleteCount = 0
        BEGIN
            RAISERROR('No valid question IDs provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 8: التحقق من وجود الأسئلة في الـ Exam
        --         [NEW #3] لو @SkipNotFound = 1 → print warning وكمّل
        -- ==============================================================
        DECLARE @NotFoundCount INT;

        SELECT @NotFoundCount = COUNT(*)
        FROM   @QDistinct QT
        LEFT JOIN [exams].ExamQuestion EQ
               ON EQ.QuestionId = QT.QuestionId
              AND EQ.ExamId     = @ExamId
        WHERE  EQ.QuestionId IS NULL;

        IF @NotFoundCount > 0
        BEGIN
            IF @SkipNotFound = 0
            BEGIN
                RAISERROR(
                    '%d question(s) are not assigned to this exam. Use @SkipNotFound = 1 to skip them.',
                    16, 1, @NotFoundCount
                );
                ROLLBACK; RETURN;
            END
            ELSE
                PRINT 'Note: ' + CAST(@NotFoundCount AS NVARCHAR(10))
                    + ' question(s) not found in exam were skipped.';
        END

        -- ==============================================================
        -- STEP 9: حساب الأسئلة اللي هتتحذف فعلاً (الموجودة بس)
        -- ==============================================================
        DECLARE @ActualToDelete INT;

        SELECT @ActualToDelete = COUNT(*)
        FROM   @QDistinct QT
        INNER JOIN [exams].ExamQuestion EQ
               ON EQ.QuestionId = QT.QuestionId
              AND EQ.ExamId     = @ExamId;

        -- ==============================================================
        -- STEP 10: منع حذف كل الأسئلة (لازم يفضل سؤال واحد على الأقل)
        -- ==============================================================
        DECLARE @CurrentQCount INT;

        SELECT @CurrentQCount = COUNT(*)
        FROM   [exams].ExamQuestion
        WHERE  ExamId = @ExamId;

        IF @CurrentQCount - @ActualToDelete < 1
        BEGIN
            RAISERROR('Cannot remove all questions from an exam. At least 1 question must remain.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 11: Delete (الموجودين في الـ Exam فقط)
        -- ==============================================================
        DELETE EQ
        FROM   [exams].ExamQuestion EQ
        INNER JOIN @QDistinct QT ON EQ.QuestionId = QT.QuestionId
        WHERE  EQ.ExamId = @ExamId;

        DECLARE @ActualRemoved INT = @@ROWCOUNT;
        SET @RemovedCount = @ActualRemoved;    -- [NEW #4] Output Parameter

        COMMIT TRANSACTION;
        PRINT 'Question(s) removed successfully from Exam ID = ' + CAST(@ExamId AS NVARCHAR(10))
            + ' | Removed: '   + CAST(@ActualRemoved AS NVARCHAR(10))
            + ' | Remaining: ' + CAST(@CurrentQCount - @ActualRemoved AS NVARCHAR(10));

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @ErrMsg NVARCHAR(2000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END
GO


-- =====================================================================
--  TEST CASES  (v2)
-- =====================================================================

-- ── stp_AddExamQuestion ──────────────────────────────────────────────

-- Test 1: مدرس مش في السيستم / مش نشط (should fail)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 1, @QuestionIds = '9,10';
GO

-- Test 2: Exam مش موجود (should fail)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 9999, @QuestionIds = '9,10';
GO

-- Test 3: سؤال من Course تانية (should fail)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 1, @QuestionIds = '4,5';
GO

-- Test 4: أسئلة موجودة بالفعل + @SkipExisting = 0 (should fail + hint)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 1, @QuestionIds = '1,2,9';
GO

-- Test 5: أسئلة موجودة بالفعل + @SkipExisting = 1 (should succeed - يضيف 9 فقط)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 1, @QuestionIds = '1,2,9', @SkipExisting = 1;
GO

-- Test 6: إضافة جديدة صحيحة مع Output Parameter
DECLARE @Added INT;
EXEC [exams].stp_AddExamQuestion
    @ExamId = 1, @QuestionIds = '10,11', @AddedCount = @Added OUTPUT;
PRINT 'Returned @AddedCount = ' + CAST(@Added AS NVARCHAR(10));
GO

-- Test 7: Duplicate IDs في الـ Input (should succeed + note)
EXEC [exams].stp_AddExamQuestion
    @ExamId = 2, @QuestionIds = '4,4,5,5,5';
GO

-- ── stp_UpdateExamQuestion ───────────────────────────────────────────

-- Test 8: Single swap صح (should succeed)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @OldQuestionId = 1, @NewQuestionId = 12;
GO

-- Test 9: Old = New (should fail)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @OldQuestionId = 2, @NewQuestionId = 2;
GO

-- Test 10: OldId مش موجود في الـ Exam (should fail)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @OldQuestionId = 999, @NewQuestionId = 1;
GO

-- Test 11: NewId من Course تانية (should fail)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @OldQuestionId = 2, @NewQuestionId = 4;
GO

-- Test 12: Multi-swap صح (should succeed)
-- بنبدل سؤالين في نفس الوقت
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @SwapList = '2:9, 3:10';
GO

-- Test 13: إدخال SwapList و Single في نفس الوقت (should fail)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1,
    @OldQuestionId = 1, @NewQuestionId = 2,
    @SwapList = '1:2';
GO

-- Test 14: SwapList بـ format غلط (should fail)
EXEC [exams].stp_UpdateExamQuestion
    @ExamId = 1, @SwapList = '1-2, 3-4';
GO

-- ── stp_DeleteExamQuestion ───────────────────────────────────────────

-- Test 15: حذف أسئلة موجودة صح (should succeed)
DECLARE @Removed INT;
EXEC [exams].stp_DeleteExamQuestion
    @ExamId = 1, @QuestionIds = '10,11', @RemovedCount = @Removed OUTPUT;
PRINT 'Returned @RemovedCount = ' + CAST(@Removed AS NVARCHAR(10));
GO

-- Test 16: سؤال مش موجود + @SkipNotFound = 0 (should fail + hint)
EXEC [exams].stp_DeleteExamQuestion
    @ExamId = 1, @QuestionIds = '999';
GO

-- Test 17: سؤال مش موجود + @SkipNotFound = 1 (should succeed with note)
EXEC [exams].stp_DeleteExamQuestion
    @ExamId = 1, @QuestionIds = '999,2', @SkipNotFound = 1;
GO

-- Test 18: محاولة حذف كل الأسئلة (should fail)
EXEC [exams].stp_DeleteExamQuestion
    @ExamId = 1, @QuestionIds = '1,2,3,9,10,11,12';
GO

-- Test 19: Exam مش موجود (should fail)
EXEC [exams].stp_DeleteExamQuestion
    @ExamId = 9999, @QuestionIds = '1';
GO

SELECT * FROM [exams].ExamQuestion WHERE ExamId IN (1, 2);
GO

