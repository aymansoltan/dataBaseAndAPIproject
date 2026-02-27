USE [ExaminationSystemDB]
GO

-- =====================================================================
--  stp_CreateExam  (v4 - Fixed)
--
--  الإصلاحات على النسخة السابقة:
--  [FIX #1] إضافة isActive = 1 على الـ Instructor
--  [FIX #2] التحقق من توافق BranchId/TrackId/IntakeId مع الـ CourseInstance
--  [FIX #3] تهيئة @FillTypes = '' عند الإعلان لتجنب NULL في رسائل الـ Warning
--  [FIX #4] معالجة Error 2627 (Duplicate Key) في الـ CATCH
--  [FIX #5] تفريق رسالة الخطأ بين "مش موجود" و"مش بتاعك" في STEP 2
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_CreateExam
    @ExamTitle        NVARCHAR(100),
    @ExamType         NVARCHAR(20)  = 'Regular',
    @StartTime        DATETIME,
    @EndTime          DATETIME,
    @CourseInstanceId INT,
    @BranchId         INT,
    @TrackId          INT,
    @IntakeId         INT,
    @Mode             NVARCHAR(10),
    @QuestionIds      NVARCHAR(MAX) = NULL,
    @QuestionCount    INT           = NULL,
    @MCQCount         INT           = NULL,
    @TFCount          INT           = NULL,
    @TextCount        INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- STEP 1: Role Check – المدرسين النشطين فقط
      
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I ON UA.UserId = I.UserId 
        AND I.isActive = 1
        WHERE  UA.UserName = SUSER_NAME()
      

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied. Only active instructors can create exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- STEP 2: التحقق من وجود CourseInstance + الملكية + CourseId
     
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE CourseInstanceId = @CourseInstanceId
        )
        BEGIN
            RAISERROR('CourseInstance not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        DECLARE @CourseId INT;

        SELECT @CourseId = CI.CourseId
        FROM   [Courses].CourseInstance CI
        WHERE  CI.CourseInstanceId = @CourseInstanceId
          AND  CI.InstructorId     = @CurrentInsId;

        IF @CourseId IS NULL
        BEGIN
            RAISERROR('Access Denied: This CourseInstance does not belong to you.', 16, 1);
            ROLLBACK; RETURN;
        END


         IF LEN(TRIM(@ExamTitle)) < 3
        BEGIN
            RAISERROR('Exam title must be at least 3 characters.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: التأكد من أن التواريخ غير NULL
        -- ==============================================================
        IF @StartTime IS NULL OR @EndTime IS NULL
        BEGIN
            RAISERROR('StartTime and EndTime must be provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Instructor Time Conflict
        -- ==============================================================
        IF EXISTS (
            SELECT 1
            FROM   [exams].Exam E
            JOIN   [Courses].CourseInstance CI ON E.CourseInstanceId = CI.CourseInstanceId
            WHERE  CI.InstructorId = @CurrentInsId
              AND  E.IsDeleted     = 0
              AND  @StartTime < E.EndTime
              AND  @EndTime   > E.StartTime
        )
        BEGIN
            RAISERROR('You already have another exam scheduled during this time slot.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: ExamTitle Validation
        -- ==============================================================
        IF LEN(TRIM(@ExamTitle)) < 3
        BEGIN
            RAISERROR('Exam title must be at least 3 characters.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: Title Uniqueness (على نفس CourseInstance)
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Exam
            WHERE  TRIM(ExamTitle)  = TRIM(@ExamTitle)
              AND  CourseInstanceId = @CourseInstanceId
              AND  IsDeleted        = 0
        )
        BEGIN
            RAISERROR('An exam with this title already exists for the same Course Instance.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: ExamType Validation
        -- ==============================================================
        IF @ExamType NOT IN ('Regular', 'Corrective')
        BEGIN
            RAISERROR('Exam type must be either Regular or Corrective.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 8: Time Validations
        -- ==============================================================
        IF @EndTime <= @StartTime
        BEGIN
            RAISERROR('EndTime must be after StartTime.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF DATEDIFF(MINUTE, @StartTime, @EndTime) < 30
        BEGIN
            RAISERROR('Exam duration must be at least 30 minutes.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF DATEDIFF(MINUTE, @StartTime, @EndTime) > 180
        BEGIN
            RAISERROR('Exam duration cannot exceed 3 hours (180 minutes).', 16, 1);
            ROLLBACK; RETURN;
        END

        IF CAST(@StartTime AS TIME) < '08:00:00'
        BEGIN
            RAISERROR('Exam start time must be 08:00 AM or later.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF CAST(@EndTime AS TIME) > '23:00:00'
        BEGIN
            RAISERROR('Exam end time must be 11:00 PM or earlier.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 9: Branch / Track / Intake Active Checks
        -- ==============================================================
        IF NOT EXISTS (SELECT 1 FROM [orgnization].Branch WHERE BranchId = @BranchId AND isActive = 1)
        BEGIN
            RAISERROR('Branch not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM [orgnization].Track WHERE TrackId = @TrackId AND isActive = 1)
        BEGIN
            RAISERROR('Track not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM [orgnization].Intake WHERE IntakeId = @IntakeId AND isActive = 1)
        BEGIN
            RAISERROR('Intake not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 10: BranchId/TrackId/IntakeId توافق مع الـ CourseInstance
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseInstanceId = @CourseInstanceId
              AND  (BranchId != @BranchId OR TrackId != @TrackId OR IntakeId != @IntakeId)
        )
        BEGIN
            RAISERROR('The provided Branch/Track/Intake do not match the selected CourseInstance.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 11: StartTime must be in the Future
        -- ==============================================================
        IF @StartTime < GETDATE()
        BEGIN
            RAISERROR('Exam start time must be in the future.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 12: Track/Intake Time Conflict
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Exam
            WHERE  TrackId   = @TrackId
              AND  IntakeId  = @IntakeId
              AND  IsDeleted = 0
              AND  @StartTime < EndTime
              AND  @EndTime   > StartTime
        )
        BEGIN
            RAISERROR('This track already has an exam scheduled during this time slot.', 16, 1);
            ROLLBACK; RETURN;
        END

-- ══════════════════════════════════════════════════════════════════
        -- STEP 13: Validate Mode
        -- ══════════════════════════════════════════════════════════════════
        IF @Mode NOT IN ('Manual', 'Random')
        BEGIN
            RAISERROR('Mode must be Manual or Random.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ══════════════════════════════════════════════════════════════════
        -- STEP 14: Insert Exam
        -- ══════════════════════════════════════════════════════════════════
        DECLARE @ExamId INT;

        INSERT INTO [exams].Exam
            (ExamTitle, ExamType, StartTime, EndTime,
             CourseInstanceId, BranchId, TrackId, IntakeId)
        VALUES
            (TRIM(@ExamTitle), @ExamType, @StartTime, @EndTime,
             @CourseInstanceId, @BranchId, @TrackId, @IntakeId);

        SET @ExamId = SCOPE_IDENTITY();

        -- ══════════════════════════════════════════════════════════════════
        -- STEP 15: Handle Questions
        -- ══════════════════════════════════════════════════════════════════

        -- ── Manual Mode ──────────────────────────────────────────────────
        IF @Mode = 'Manual'
        BEGIN
            IF @QuestionIds IS NULL OR TRIM(@QuestionIds) = ''
            BEGIN
                RAISERROR('QuestionIds must be provided for Manual mode.', 16, 1);
                ROLLBACK; RETURN;
            END

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
                RAISERROR('No valid question IDs provided for Manual mode.', 16, 1);
                ROLLBACK; RETURN;
            END

            IF @RawCount > @DistinctCount
                PRINT 'Note: ' + CAST(@RawCount - @DistinctCount AS NVARCHAR(10))
                    + ' duplicate question ID(s) were ignored. '
                    + CAST(@DistinctCount AS NVARCHAR(10))
                    + ' unique question(s) will be added.';

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
                RAISERROR('One or more questions do not belong to this Course or are deleted.', 16, 1);
                ROLLBACK; RETURN;
            END

            INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
            SELECT @ExamId, QuestionId
            FROM   @QDistinct;

            COMMIT TRANSACTION;
            PRINT 'Exam created successfully: ' + @ExamTitle
                + ' | Questions added: ' + CAST(@DistinctCount AS NVARCHAR(10));
        END

        -- ── Random Mode ───────────────────────────────────────────────────
        ELSE IF @Mode = 'Random'
        BEGIN
            -- QuestionCount is required
            IF @QuestionCount IS NULL
            BEGIN
                RAISERROR('QuestionCount is required for Random mode.', 16, 1);
                ROLLBACK; RETURN;
            END

            IF @QuestionCount <= 0
            BEGIN
                RAISERROR('QuestionCount must be greater than 0.', 16, 1);
                ROLLBACK; RETURN;
            END

            -- Type counts cannot be negative
            IF ISNULL(@MCQCount, 0) < 0
            OR ISNULL(@TFCount,  0) < 0
            OR ISNULL(@TextCount,0) < 0
            BEGIN
                RAISERROR('Question type counts cannot be negative.', 16, 1);
                ROLLBACK; RETURN;
            END

            -- Normalize nulls to 0
            SET @MCQCount  = ISNULL(@MCQCount,  0);
            SET @TFCount   = ISNULL(@TFCount,   0);
            SET @TextCount = ISNULL(@TextCount, 0);

            DECLARE @TypesTotal INT = @MCQCount + @TFCount + @TextCount;

            -- Type counts cannot exceed QuestionCount
            IF @TypesTotal > @QuestionCount
            BEGIN
                RAISERROR(
                    'Sum of type counts (%d) cannot exceed QuestionCount (%d).',
                    16, 1, @TypesTotal, @QuestionCount
                );
                ROLLBACK; RETURN;
            END

            -- Check total available
            DECLARE @TotalAvailable INT;

            SELECT @TotalAvailable = COUNT(*)
            FROM   [exams].Question
            WHERE  CourseId  = @CourseId
              AND  IsDeleted = 0;

            IF @TotalAvailable < @QuestionCount
            BEGIN
                RAISERROR(
                    'Not enough questions available. Requested: %d | Available: %d',
                    16, 1, @QuestionCount, @TotalAvailable
                );
                ROLLBACK; RETURN;
            END

            -- Check availability per type
            DECLARE @AvailMCQ  INT,
                    @AvailTF   INT,
                    @AvailText INT;

            SELECT
                @AvailMCQ  = SUM(CASE WHEN QuestionType = 'MCQ'  THEN 1 ELSE 0 END),
                @AvailTF   = SUM(CASE WHEN QuestionType = 'T/F'  THEN 1 ELSE 0 END),
                @AvailText = SUM(CASE WHEN QuestionType = 'Text' THEN 1 ELSE 0 END)
            FROM [exams].Question
            WHERE CourseId  = @CourseId
              AND IsDeleted = 0;

            SET @AvailMCQ  = ISNULL(@AvailMCQ,  0);
            SET @AvailTF   = ISNULL(@AvailTF,   0);
            SET @AvailText = ISNULL(@AvailText, 0);

            IF @MCQCount > @AvailMCQ
            BEGIN
                RAISERROR(
                    'Not enough MCQ questions. Requested: %d | Available: %d',
                    16, 1, @MCQCount, @AvailMCQ
                );
                ROLLBACK; RETURN;
            END

            IF @TFCount > @AvailTF
            BEGIN
                RAISERROR(
                    'Not enough T/F questions. Requested: %d | Available: %d',
                    16, 1, @TFCount, @AvailTF
                );
                ROLLBACK; RETURN;
            END

            IF @TextCount > @AvailText
            BEGIN
                RAISERROR(
                    'Not enough Text questions. Requested: %d | Available: %d',
                    16, 1, @TextCount, @AvailText
                );
                ROLLBACK; RETURN;
            END

            -- Track selected questions to avoid duplicates
            DECLARE @SelectedQ TABLE (QuestionId INT);

            -- Insert specified MCQ
            IF @MCQCount > 0
            BEGIN
                INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
                OUTPUT INSERTED.QuestionId INTO @SelectedQ
                SELECT TOP (@MCQCount) @ExamId, QuestionId
                FROM   [exams].Question
                WHERE  CourseId     = @CourseId
                  AND  QuestionType = 'MCQ'
                  AND  IsDeleted    = 0
                ORDER BY NEWID();
            END

            -- Insert specified T/F
            IF @TFCount > 0
            BEGIN
                INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
                OUTPUT INSERTED.QuestionId INTO @SelectedQ
                SELECT TOP (@TFCount) @ExamId, QuestionId
                FROM   [exams].Question
                WHERE  CourseId     = @CourseId
                  AND  QuestionType = 'T/F'
                  AND  IsDeleted    = 0
                ORDER BY NEWID();
            END

            -- Insert specified Text
            IF @TextCount > 0
            BEGIN
                INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
                OUTPUT INSERTED.QuestionId INTO @SelectedQ
                SELECT TOP (@TextCount) @ExamId, QuestionId
                FROM   [exams].Question
                WHERE  CourseId     = @CourseId
                  AND  QuestionType = 'Text'
                  AND  IsDeleted    = 0
                ORDER BY NEWID();
            END

            -- Fill remaining randomly from any type
            DECLARE @Remaining INT = @QuestionCount - @TypesTotal;

            IF @Remaining > 0
            BEGIN
                DECLARE @LeftOver INT;

                SELECT @LeftOver = COUNT(*)
                FROM   [exams].Question
                WHERE  CourseId   = @CourseId
                  AND  IsDeleted  = 0
                  AND  QuestionId NOT IN (SELECT QuestionId FROM @SelectedQ);

                IF @LeftOver < @Remaining
                BEGIN
                    RAISERROR(
                        'Not enough remaining questions for random fill. Need: %d | Left: %d',
                        16, 1, @Remaining, @LeftOver
                    );
                    ROLLBACK; RETURN;
                END

                INSERT INTO [exams].ExamQuestion (ExamId, QuestionId)
                OUTPUT INSERTED.QuestionId INTO @SelectedQ
                SELECT TOP (@Remaining) @ExamId, QuestionId
                FROM   [exams].Question
                WHERE  CourseId   = @CourseId
                  AND  IsDeleted  = 0
                  AND  QuestionId NOT IN (SELECT QuestionId FROM @SelectedQ)
                ORDER BY NEWID();

                IF @TypesTotal > 0
                    PRINT 'Note: ' + CAST(@Remaining AS NVARCHAR(10))
                        + ' question(s) were filled randomly to reach QuestionCount of '
                        + CAST(@QuestionCount AS NVARCHAR(10)) + '.';
            END

                DECLARE @TotalAdded INT;
                SELECT @TotalAdded = COUNT(*)
                FROM [exams].ExamQuestion
                WHERE ExamId = @ExamId;

            COMMIT TRANSACTION;
            PRINT 'Exam created successfully: ' + @ExamTitle
                + ' | Total questions added: ' + CAST(@TotalAdded AS NVARCHAR(10));
        END

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: an exam with these details already exists.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_UpdateExam
--
--  المميزات:
--  - Role Check من SUSER_NAME() (admin أو instructor نشط)
--  - منع الـ instructor من استخدام @IsDeleted = 1
--  - Time Lock: منع التعديل قبل الامتحان بساعة
--  - منع التعديل لو طلاب بدأوا
--  - CourseInstance existence check قبل Ownership
--  - Title Uniqueness (باستثناء الـ Exam نفسه)
--  - توافق Branch/Track/Intake مع الـ CourseInstance
--  - Max Duration (180 دقيقة)
--  - لو تغير الـ CourseInstance لـ Course تاني → حذف الأسئلة القديمة مع warning
--  - معالجة Error 2627 في الـ CATCH
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_UpdateExam
    @ExamId           INT,
    @ExamTitle        NVARCHAR(100),
    @ExamType         NVARCHAR(20) = 'Regular',
    @StartTime        DATETIME,
    @EndTime          DATETIME,
    @CourseInstanceId INT,
    @BranchId         INT,
    @TrackId          INT,
    @IntakeId         INT,
    @IsDeleted        BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check من SUSER_NAME()
        -- ==============================================================
        DECLARE @CurrentRole_Upd  NVARCHAR(50),
                @CurrentInsId_Upd INT;

        SELECT @CurrentRole_Upd  = R.RoleName,
               @CurrentInsId_Upd = I.InsId
        FROM   [userAcc].UserAccount  UA
        JOIN   [userAcc].UserRole     R  ON UA.RoleId = R.RoleId
        LEFT JOIN [userAcc].Instructor I  ON UA.UserId = I.UserId AND I.isActive = 1
        WHERE  UA.UserName = SUSER_NAME();

        IF @CurrentRole_Upd NOT IN ('admin', 'instructor')
        BEGIN
            RAISERROR('Access Denied: You do not have permission to update exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- منع الـ instructor من @IsDeleted = 1
        IF @IsDeleted = 1 AND @CurrentRole_Upd != 'admin'
        BEGIN
            RAISERROR('Access Denied: Only admins can soft-delete exams through update.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: جيب بيانات الامتحان الحالي
        -- ==============================================================
        DECLARE @ExamIsDeleted_Upd   BIT,
                @ExamCurrentStart    DATETIME,
                @OldCourseInstanceId INT;

        SELECT @ExamIsDeleted_Upd   = IsDeleted,
               @ExamCurrentStart    = StartTime,
               @OldCourseInstanceId = CourseInstanceId
        FROM   [exams].Exam
        WHERE  ExamId = @ExamId;

        IF @ExamIsDeleted_Upd IS NULL
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @ExamIsDeleted_Upd = 1
        BEGIN
            RAISERROR('Cannot update a deleted exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership على الـ Exam الحالي
        -- ==============================================================
        IF @CurrentRole_Upd = 'instructor' AND NOT EXISTS (
            SELECT 1
            FROM   [exams].Exam             E
            JOIN   [Courses].CourseInstance CI ON E.CourseInstanceId = CI.CourseInstanceId
            WHERE  E.ExamId          = @ExamId
              AND  CI.InstructorId   = @CurrentInsId_Upd
        )
        BEGIN
            RAISERROR('Access Denied: You can only update exams for your own course instances.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Time Lock – منع التعديل قبل الامتحان بساعة
        -- ==============================================================
        IF GETDATE() >= DATEADD(HOUR, -1, @ExamCurrentStart)
        BEGIN
            RAISERROR('Cannot update exam: the exam is locked 1 hour before it starts.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: منع التعديل لو طلاب بدأوا
        -- ==============================================================
        IF EXISTS (SELECT 1 FROM [exams].Student_Answer      WHERE ExamId = @ExamId)
        OR EXISTS (SELECT 1 FROM [exams].Student_Exam_Result WHERE ExamId = @ExamId)
        BEGIN
            RAISERROR('Cannot update exam: one or more students have already started this exam.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: التأكد من أن التواريخ غير NULL
        -- ==============================================================
        IF @StartTime IS NULL OR @EndTime IS NULL
        BEGIN
            RAISERROR('StartTime and EndTime must be provided.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: ExamTitle Validation
        -- ==============================================================
        IF LEN(TRIM(@ExamTitle)) < 3
        BEGIN
            RAISERROR('Exam title must be at least 3 characters.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 8: Title Uniqueness (باستثناء الـ Exam نفسه)
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Exam
            WHERE  TRIM(ExamTitle)  = TRIM(@ExamTitle)
              AND  CourseInstanceId = @CourseInstanceId
              AND  ExamId          != @ExamId
              AND  IsDeleted        = 0
        )
        BEGIN
            RAISERROR('An exam with this title already exists for the same Course Instance.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 9: ExamType Validation
        -- ==============================================================
        IF @ExamType NOT IN ('Regular', 'Corrective')
        BEGIN
            RAISERROR('Exam type must be either Regular or Corrective.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 10: Time Validations
        -- ==============================================================
        IF @EndTime <= @StartTime
        BEGIN
            RAISERROR('EndTime must be after StartTime.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF DATEDIFF(MINUTE, @StartTime, @EndTime) < 30
        BEGIN
            RAISERROR('Exam duration must be at least 30 minutes.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF DATEDIFF(MINUTE, @StartTime, @EndTime) > 180
        BEGIN
            RAISERROR('Exam duration cannot exceed 3 hours (180 minutes).', 16, 1);
            ROLLBACK; RETURN;
        END

        IF CAST(@StartTime AS TIME) < '08:00:00'
        BEGIN
            RAISERROR('Exam start time must be 08:00 AM or later.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF CAST(@EndTime AS TIME) > '23:00:00'
        BEGIN
            RAISERROR('Exam end time must be 11:00 PM or earlier.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 11: CourseInstance Exists
        -- ==============================================================
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE CourseInstanceId = @CourseInstanceId
        )
        BEGIN
            RAISERROR('CourseInstance not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 12: توافق Branch/Track/Intake مع الـ CourseInstance
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseInstanceId = @CourseInstanceId
              AND  (BranchId != @BranchId OR TrackId != @TrackId OR IntakeId != @IntakeId)
        )
        BEGIN
            RAISERROR('The provided Branch/Track/Intake do not match the selected CourseInstance.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 13: Instructor Time Conflict (باستثناء الـ Exam نفسه)
        -- ==============================================================
        DECLARE @InstructorId_Upd INT;

        SELECT @InstructorId_Upd = InstructorId
        FROM   [Courses].CourseInstance
        WHERE  CourseInstanceId = @CourseInstanceId;

        IF EXISTS (
            SELECT 1
            FROM   [exams].Exam             E
            JOIN   [Courses].CourseInstance CI ON E.CourseInstanceId = CI.CourseInstanceId
            WHERE  CI.InstructorId = @InstructorId_Upd
              AND  E.IsDeleted     = 0
              AND  E.ExamId       != @ExamId
              AND  @StartTime < E.EndTime
              AND  @EndTime   > E.StartTime
        )
        BEGIN
            RAISERROR('The instructor already has an exam scheduled during this time slot.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 14: Instructor Ownership على الـ CourseInstance الجديد
        -- ==============================================================
        IF @CurrentRole_Upd = 'instructor' AND NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseInstanceId = @CourseInstanceId
              AND  InstructorId     = @CurrentInsId_Upd
        )
        BEGIN
            RAISERROR('Access Denied: The new CourseInstance does not belong to you.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 15: Branch / Track / Intake Active Checks
        -- ==============================================================
        IF NOT EXISTS (SELECT 1 FROM [orgnization].Branch WHERE BranchId = @BranchId AND isActive = 1)
        BEGIN
            RAISERROR('Branch not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM [orgnization].Track WHERE TrackId = @TrackId AND isActive = 1)
        BEGIN
            RAISERROR('Track not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM [orgnization].Intake WHERE IntakeId = @IntakeId AND isActive = 1)
        BEGIN
            RAISERROR('Intake not found or not active.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 16: StartTime in the Future
        -- ==============================================================
        IF @StartTime < GETDATE()
        BEGIN
            RAISERROR('Exam start time must be in the future.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 17: Track/Intake Time Conflict (باستثناء الـ Exam نفسه)
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Exam
            WHERE  TrackId   = @TrackId
              AND  IntakeId  = @IntakeId
              AND  ExamId   != @ExamId
              AND  IsDeleted = 0
              AND  @StartTime < EndTime
              AND  @EndTime   > StartTime
        )
        BEGIN
            RAISERROR('This track already has an exam scheduled during this time slot.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 18: لو تغير الـ CourseInstance لـ Course تاني →
        --          احذف الأسئلة القديمة مع warning للمدرس
        -- ==============================================================
        DECLARE @OldCourseId INT, @NewCourseId INT;

        SELECT @OldCourseId = CourseId
        FROM   [Courses].CourseInstance
        WHERE  CourseInstanceId = @OldCourseInstanceId;

        SELECT @NewCourseId = CourseId
        FROM   [Courses].CourseInstance
        WHERE  CourseInstanceId = @CourseInstanceId;

        IF @OldCourseId != @NewCourseId
        BEGIN
            DECLARE @DeletedQCount INT;

            SELECT @DeletedQCount = COUNT(*)
            FROM   [exams].ExamQuestion
            WHERE  ExamId = @ExamId;

            IF @DeletedQCount > 0
            BEGIN
                DELETE FROM [exams].ExamQuestion WHERE ExamId = @ExamId;

                PRINT '⚠ Warning: Course changed. '
                    + CAST(@DeletedQCount AS NVARCHAR(10))
                    + ' old question(s) removed. Please re-add questions for the new course.';
            END
        END

        -- ==============================================================
        -- STEP 19: Update
        -- ==============================================================
        UPDATE [exams].Exam
        SET
            ExamTitle        = TRIM(@ExamTitle),
            ExamType         = @ExamType,
            StartTime        = @StartTime,
            EndTime          = @EndTime,
            CourseInstanceId = @CourseInstanceId,
            BranchId         = @BranchId,
            TrackId          = @TrackId,
            IntakeId         = @IntakeId,
            IsDeleted        = @IsDeleted
        WHERE ExamId = @ExamId;

        COMMIT TRANSACTION;
        PRINT 'Exam updated successfully. ID = ' + CAST(@ExamId AS NVARCHAR(10));

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: an exam with these details already exists.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg_Upd NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg_Upd, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_DeleteExam
--
--  المميزات:
--  - Role Check من SUSER_NAME() (admin أو instructor نشط)
--  - Instructor Ownership
--  - Time Lock: منع الحذف قبل الامتحان بساعة
--  - الـ Trigger هو اللي يقرر: Soft أو Hard Delete
--  - معالجة Error 2627 في الـ CATCH
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_DeleteExam
    @ExamId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check من SUSER_NAME()
        -- ==============================================================
        DECLARE @CurrentRole_Del  NVARCHAR(50),
                @CurrentInsId_Del INT;

        SELECT @CurrentRole_Del  = R.RoleName,
               @CurrentInsId_Del = I.InsId
        FROM   [userAcc].UserAccount  UA
        JOIN   [userAcc].UserRole     R  ON UA.RoleId = R.RoleId
        LEFT JOIN [userAcc].Instructor I  ON UA.UserId = I.UserId AND I.isActive = 1
        WHERE  UA.UserName = SUSER_NAME();

        IF @CurrentRole_Del NOT IN ('admin', 'instructor')
        BEGIN
            RAISERROR('Access Denied: You do not have permission to delete exams.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: جيب بيانات الامتحان
        -- ==============================================================
        DECLARE @ExamIsDeleted_Del BIT,
                @ExamStartTime_Del DATETIME;

        SELECT @ExamIsDeleted_Del = IsDeleted,
               @ExamStartTime_Del = StartTime
        FROM   [exams].Exam
        WHERE  ExamId = @ExamId;

        IF @ExamIsDeleted_Del IS NULL
        BEGIN
            RAISERROR('Exam not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @ExamIsDeleted_Del = 1
        BEGIN
            RAISERROR('Exam is already deleted.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership
        -- ==============================================================
        IF @CurrentRole_Del = 'instructor' AND NOT EXISTS (
            SELECT 1
            FROM   [exams].Exam             E
            JOIN   [Courses].CourseInstance CI ON E.CourseInstanceId = CI.CourseInstanceId
            WHERE  E.ExamId        = @ExamId
              AND  CI.InstructorId = @CurrentInsId_Del
        )
        BEGIN
            RAISERROR('Access Denied: You can only delete exams for your own course instances.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Time Lock – منع الحذف قبل الامتحان بساعة
        -- ==============================================================
        IF GETDATE() >= DATEADD(HOUR, -1, @ExamStartTime_Del)
        BEGIN
            RAISERROR('Cannot delete exam: the exam is locked 1 hour before it starts.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: Delete (الـ Trigger يقرر Soft أو Hard)
        -- ==============================================================
        DELETE FROM [exams].Exam WHERE ExamId = @ExamId;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @ErrMsg_Del NVARCHAR(2000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg_Del, 16, 1);
    END CATCH
END
GO


-- =====================================================================
--  trg_SoftDeleteExam
--
--  المميزات:
--  - Soft Delete لو الامتحان عنده علاقات (Student_Answer, Result, ExamQuestion)
--  - Hard Delete لو مفيش أي علاقات
--  - بيحسب الـ SoftCount و HardCount قبل أي عملية (@@ROWCOUNT fix)
--  - Print واضح لكل حالة
-- =====================================================================
CREATE OR ALTER TRIGGER [exams].trg_SoftDeleteExam
ON [exams].Exam
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- حساب كام exam هيتعمله Soft وكام هيتعمله Hard (قبل أي عملية)
    DECLARE @SoftCount INT = 0,
            @HardCount INT = 0;

    SELECT @SoftCount = COUNT(*)
    FROM   deleted D
    WHERE  EXISTS (SELECT 1 FROM [exams].Student_Answer      SA WHERE SA.ExamId = D.ExamId)
    OR     EXISTS (SELECT 1 FROM [exams].Student_Exam_Result SR WHERE SR.ExamId = D.ExamId)
    OR     EXISTS (SELECT 1 FROM [exams].ExamQuestion        EQ WHERE EQ.ExamId = D.ExamId);

    SELECT @HardCount = COUNT(*)
    FROM   deleted D
    WHERE  NOT EXISTS (SELECT 1 FROM [exams].Student_Answer      SA WHERE SA.ExamId = D.ExamId)
    AND    NOT EXISTS (SELECT 1 FROM [exams].Student_Exam_Result SR WHERE SR.ExamId = D.ExamId)
    AND    NOT EXISTS (SELECT 1 FROM [exams].ExamQuestion        EQ WHERE EQ.ExamId = D.ExamId);

    -- Soft Delete: عنده علاقات → IsDeleted = 1
    IF @SoftCount > 0
    BEGIN
        UPDATE E
        SET    E.IsDeleted = 1
        FROM   [exams].Exam E
        INNER JOIN deleted D ON E.ExamId = D.ExamId
        WHERE  EXISTS (SELECT 1 FROM [exams].Student_Answer      SA WHERE SA.ExamId = D.ExamId)
        OR     EXISTS (SELECT 1 FROM [exams].Student_Exam_Result SR WHERE SR.ExamId = D.ExamId)
        OR     EXISTS (SELECT 1 FROM [exams].ExamQuestion        EQ WHERE EQ.ExamId = D.ExamId);

        PRINT 'Soft Delete applied for '
            + CAST(@SoftCount AS NVARCHAR(10))
            + ' exam(s) — has related data, marked as deleted.';
    END

    -- Hard Delete: مفيش علاقات → احذفه فعلاً
    IF @HardCount > 0
    BEGIN
        DELETE E
        FROM   [exams].Exam E
        INNER JOIN deleted D ON E.ExamId = D.ExamId
        WHERE  NOT EXISTS (SELECT 1 FROM [exams].Student_Answer      SA WHERE SA.ExamId = D.ExamId)
        AND    NOT EXISTS (SELECT 1 FROM [exams].Student_Exam_Result SR WHERE SR.ExamId = D.ExamId)
        AND    NOT EXISTS (SELECT 1 FROM [exams].ExamQuestion        EQ WHERE EQ.ExamId = D.ExamId);

        PRINT 'Hard Delete applied for '
            + CAST(@HardCount AS NVARCHAR(10))
            + ' exam(s) — no related data, permanently removed.';
    END
END
GO


-- =====================================================================
--  TEST CASES
-- =====================================================================

-- ── stp_CreateExam ───────────────────────────────────────────────────

-- Test 1: مدرس غير نشط (should fail)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Inactive Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 2: CourseInstance مش موجود (should fail - رسالة واضحة)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Ghost CI', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 9999, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 3: CourseInstance موجود بس مش بتاعك (should fail - رسالة مختلفة)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Not Mine', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 5, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 4: Branch/Track/Intake مش بيطابق الـ CourseInstance (should fail)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Mismatch Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 99, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 5: Valid Manual Exam (should succeed)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'SQL Final Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3,4,5';
GO

-- Test 6: Duplicate Title (should fail)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'SQL Final Exam', @ExamType = 'Regular',
    @StartTime = '2026-07-01 09:00', @EndTime = '2026-07-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 7: Duplicate IDs يتجاهلوا (should succeed + note)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Dup IDs Exam', @ExamType = 'Regular',
    @StartTime = '2026-08-01 09:00', @EndTime = '2026-08-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,2,3,3,3,4';
GO

-- Test 8: Random Total (should succeed)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Random Total', @ExamType = 'Regular',
    @StartTime = '2026-09-01 10:00', @EndTime = '2026-09-01 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @QuestionCount = 5;
GO

-- Test 9: Smart Fill - Text ناقص (should succeed + warnings)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'SmartFill Exam', @ExamType = 'Regular',
    @StartTime = '2026-10-01 09:00', @EndTime = '2026-10-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @MCQCount = 2, @TFCount = 2, @TextCount = 20;
GO

-- Test 10: المجموع أكبر من المتاح (should fail)
EXEC [exams].stp_CreateExam
    @ExamTitle = 'Impossible', @ExamType = 'Regular',
    @StartTime = '2026-11-01 09:00', @EndTime = '2026-11-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @MCQCount = 999, @TFCount = 999, @TextCount = 999;
GO

-- ── stp_UpdateExam ───────────────────────────────────────────────────

-- Test 11: Valid update (should succeed)
EXEC [exams].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'SQL Final Updated', @ExamType = 'Corrective',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 12: Exam not found (should fail)
EXEC [exams].stp_UpdateExam
    @ExamId = 999, @ExamTitle = 'Not Found', @ExamType = 'Regular',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 13: Instructor tries IsDeleted = 1 (should fail)
EXEC [exams].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Try Soft Delete', @ExamType = 'Regular',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 1;
GO

-- Test 14: Duration > 3 hours (should fail)
EXEC [exams].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Too Long Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-10 09:00', @EndTime = '2026-06-10 14:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 15: Duplicate Title في نفس CourseInstance (should fail)
EXEC [exams].stp_UpdateExam
    @ExamId = 2, @ExamTitle = 'SQL Final Updated', @ExamType = 'Regular',
    @StartTime = '2026-06-15 10:00', @EndTime = '2026-06-15 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 16: تغيير CourseInstance لـ Course تاني (يحذف الأسئلة القديمة + warning)
EXEC [exams].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Course Changed', @ExamType = 'Regular',
    @StartTime = '2026-06-20 10:00', @EndTime = '2026-06-20 12:00',
    @CourseInstanceId = 2, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- ── stp_DeleteExam ───────────────────────────────────────────────────

-- Test 17: Hard Delete - مفيش علاقات (Trigger → بيطبع "Hard Delete applied")
EXEC [exams].stp_DeleteExam @ExamId = 5;
GO

-- Test 18: Soft Delete - عنده أسئلة (Trigger → بيطبع "Soft Delete applied")
EXEC [exams].stp_DeleteExam @ExamId = 1;
GO

-- Test 19: Already soft-deleted (should fail)
EXEC [exams].stp_DeleteExam @ExamId = 1;
GO

-- Test 20: Not found (should fail)
EXEC [exams].stp_DeleteExam @ExamId = 999;
GO

-- Test 21: Exam locked قبل ساعة من البدء (should fail)
EXEC [exams].stp_DeleteExam @ExamId = 3;
GO

SELECT * FROM [exams].Exam;
GO


-----------------------------------------------------------------------------------------------



CREATE OR ALTER TRIGGER [exams].trg_UpdateExamTotalGrade
ON [exams].ExamQuestion
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- =====================================================
    -- Step 1: Collect all affected Exam IDs
    -- from both INSERT and DELETE operations
    -- =====================================================
    DECLARE @AffectedExams TABLE (ExamId INT);

    INSERT INTO @AffectedExams
    SELECT ExamId FROM inserted  -- newly added questions
    UNION
    SELECT ExamId FROM deleted;  -- removed questions

    -- =====================================================
    -- Step 2: Recalculate TotalGrade for each affected Exam
    -- by summing Points from the Question table
    -- =====================================================
    UPDATE E
    SET E.TotalGrade = (
        SELECT ISNULL(SUM(Q.Points), 0)  -- returns 0 if no questions exist
        FROM [exams].ExamQuestion EQ
        JOIN [exams].Question Q
            ON EQ.QuestionId = Q.QuestionId
        WHERE EQ.ExamId = E.ExamId
    )
    FROM [exams].Exam E
    WHERE E.ExamId IN (SELECT ExamId FROM @AffectedExams);

    -- =====================================================
    -- Step 3: Validate TotalGrade does not exceed
    -- the Course MaxDegree
    -- if exceeded → ROLLBACK, questions will not be added
    -- =====================================================
    IF EXISTS (
        SELECT 1
        FROM [exams].Exam E
        JOIN [Courses].CourseInstance CI
            ON E.CourseInstanceId = CI.CourseInstanceId
        JOIN [Courses].Course C
            ON CI.CourseId = C.CourseId
        WHERE E.ExamId IN (SELECT ExamId FROM @AffectedExams)
          AND E.TotalGrade > C.MaxDegree
    )
    BEGIN
        RAISERROR('Total grade exceeds course max degree!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- =====================================================
    -- Step 4: Validate TotalGrade is not below
    -- the Course MinDegree (only if exam has questions)
    -- if below → ROLLBACK, questions will not be added
    -- =====================================================
    IF EXISTS (
        SELECT 1
        FROM [exams].Exam E
        JOIN [Courses].CourseInstance CI
            ON E.CourseInstanceId = CI.CourseInstanceId
        JOIN [Courses].Course C
            ON CI.CourseId = C.CourseId
        WHERE E.ExamId IN (SELECT ExamId FROM @AffectedExams)
          AND E.TotalGrade > 0        -- skip empty exams
          AND E.TotalGrade < C.MinDegree
    )
    BEGIN
        RAISERROR('Total grade is below course minimum degree!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

END;





