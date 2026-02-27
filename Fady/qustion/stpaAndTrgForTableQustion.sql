USE [ExaminationSystemDB]
GO

-- =====================================================================
--  stp_CreateQuestion
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_CreateQuestion
    @QuestionText  NVARCHAR(MAX),
    @QuestionType  NVARCHAR(20),        
    @CorrectAnswer NVARCHAR(MAX) = NULL,
    @BestAnswer    NVARCHAR(MAX),
    @Points        INT           = 1,
    @CourseId      INT,
    @OptionsList   NVARCHAR(MAX) = NULL  
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check – المدرسين النشطين فقط
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I ON UA.UserId = I.UserId
        WHERE  UA.UserName = SUSER_NAME()
          AND  I.isActive  = 1;

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied. Only active instructors can create questions.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: التحقق من وجود الـ Course
        -- ==============================================================
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].Course
            WHERE CourseId = @CourseId
        )
        BEGIN
            RAISERROR('Course not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: التحقق إن المدرس بيدرّس الـ Course دي
        -- ==============================================================
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseId      = @CourseId
              AND  InstructorId  = @CurrentInsId
        )
        BEGIN
            RAISERROR('Access Denied: You do not teach this course.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: QuestionText Validation
        -- ==============================================================
        IF @QuestionText IS NULL OR LEN(TRIM(@QuestionText)) < 10
        BEGIN
            RAISERROR('Question text must be at least 10 characters.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: QuestionType Validation
        -- ==============================================================
        IF @QuestionType NOT IN ('MCQ', 'T/F', 'Text')
        BEGIN
            RAISERROR('Question type must be MCQ, T/F, or Text.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: BestAnswer مطلوب دايماً
        -- ==============================================================
        IF @BestAnswer IS NULL OR LEN(TRIM(@BestAnswer)) = 0
        BEGIN
            RAISERROR('BestAnswer is required for all question types.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: Points Validation
        -- ==============================================================
        IF @Points IS NULL OR @Points <= 0
        BEGIN
            RAISERROR('Points must be greater than 0.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 8: Type-specific Validations
        -- ==============================================================

        -- T/F: CorrectAnswer لازم يكون 'True' أو 'False'
        IF @QuestionType = 'T/F'
        BEGIN
            IF @CorrectAnswer IS NULL OR @CorrectAnswer NOT IN ('True', 'False')
            BEGIN
                RAISERROR('For T/F questions, CorrectAnswer must be ''True'' or ''False''.', 16, 1);
                ROLLBACK; RETURN;
            END
        END

        -- MCQ: CorrectAnswer مطلوب + لازم Options
        IF @QuestionType = 'MCQ'
        BEGIN
            IF @CorrectAnswer IS NULL OR LEN(TRIM(@CorrectAnswer)) = 0
            BEGIN
                RAISERROR('For MCQ questions, CorrectAnswer is required.', 16, 1);
                ROLLBACK; RETURN;
            END

            IF @OptionsList IS NULL OR LEN(TRIM(@OptionsList)) = 0
            BEGIN
                RAISERROR('For MCQ questions, @OptionsList is required (separated by |).', 16, 1);
                ROLLBACK; RETURN;
            END

            -- على الأقل 2 Options
            DECLARE @OptionsCount INT = (
                SELECT COUNT(*)
                FROM   STRING_SPLIT(@OptionsList, '|')
                WHERE  LEN(TRIM(value)) > 0
            );

            IF @OptionsCount < 2
            BEGIN
                RAISERROR('MCQ questions must have at least 2 options.', 16, 1);
                ROLLBACK; RETURN;
            END

            -- CorrectAnswer لازم يكون موجود في الـ Options
            IF NOT EXISTS (
                SELECT 1
                FROM   STRING_SPLIT(@OptionsList, '|')
                WHERE  TRIM(value) = TRIM(@CorrectAnswer)
            )
            BEGIN
                RAISERROR('CorrectAnswer must match one of the provided options exactly.', 16, 1);
                ROLLBACK; RETURN;
            END
        END

        -- Text: CorrectAnswer مش مطلوب (warning بس)
        IF @QuestionType = 'Text' AND @CorrectAnswer IS NOT NULL
            PRINT 'Note: CorrectAnswer is not used for Text questions. Only BestAnswer will be saved.';

        -- ==============================================================
        -- STEP 9: Duplicate Check – نفس الـ QuestionText على نفس الـ Course
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Question
            WHERE  CourseId      = @CourseId
              AND  QuestionText  = @QuestionText
              AND  IsDeleted     = 0
        )
        BEGIN
            RAISERROR('A question with the same text already exists in this course.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 10: Insert Question
        -- ==============================================================
        DECLARE @QuestionId INT;

        INSERT INTO [exams].Question
            (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId)
        VALUES
            (TRIM(@QuestionText),
             @QuestionType,
             CASE WHEN @QuestionType = 'Text' THEN NULL ELSE TRIM(@CorrectAnswer) END,
             TRIM(@BestAnswer),
             @Points,
             @CourseId);

        SET @QuestionId = SCOPE_IDENTITY();

        -- ==============================================================
        -- STEP 11: Insert Options (MCQ فقط)
        -- ==============================================================
        IF @QuestionType = 'MCQ'
        BEGIN
            INSERT INTO [exams].QuestionOption (QuestionOptionText, QuestionId)
            SELECT TRIM(value), @QuestionId
            FROM   STRING_SPLIT(@OptionsList, '|')
            WHERE  LEN(TRIM(value)) > 0;

            PRINT 'Question created successfully. ID = ' + CAST(@QuestionId AS NVARCHAR(10))
                + ' | Type: MCQ | Options added: ' + CAST(@OptionsCount AS NVARCHAR(10));
        END
        ELSE
        BEGIN
            PRINT 'Question created successfully. ID = ' + CAST(@QuestionId AS NVARCHAR(10))
                + ' | Type: ' + @QuestionType;
        END

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: this question already exists.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_UpdateQuestion
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_UpdateQuestion
    @QuestionId    INT,
    @QuestionText  NVARCHAR(MAX),
    @QuestionType  NVARCHAR(20),
    @CorrectAnswer NVARCHAR(MAX) = NULL,
    @BestAnswer    NVARCHAR(MAX),
    @Points        INT           = 1,
    @OptionsList   NVARCHAR(MAX) = NULL  
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check – المدرسين النشطين فقط
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I ON UA.UserId = I.UserId
        WHERE  UA.UserName = SUSER_NAME()
          AND  I.isActive  = 1;

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied. Only active instructors can update questions.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: Question Exists + مش محذوف
        -- ==============================================================
        DECLARE @OldType    NVARCHAR(20),
                @CourseId   INT,
                @IsDeleted  BIT;

        SELECT @OldType   = QuestionType,
               @CourseId  = CourseId,
               @IsDeleted = IsDeleted
        FROM   [exams].Question
        WHERE  QuestionId = @QuestionId;

        IF @OldType IS NULL
        BEGIN
            RAISERROR('Question not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @IsDeleted = 1
        BEGIN
            RAISERROR('Cannot update a deleted question.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership على الـ Course
        -- ==============================================================
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseId     = @CourseId
              AND  InstructorId = @CurrentInsId
        )
        BEGIN
            RAISERROR('Access Denied: You do not teach the course this question belongs to.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: منع التعديل لو طالب عنده إجابة على السؤال ده
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Student_Answer
            WHERE QuestionId = @QuestionId
        )
        BEGIN
            RAISERROR('Cannot update question: one or more students have already answered this question.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 5: QuestionText Validation
        -- ==============================================================
        IF @QuestionText IS NULL OR LEN(TRIM(@QuestionText)) < 10
        BEGIN
            RAISERROR('Question text must be at least 10 characters.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 6: QuestionType Validation
        -- ==============================================================
        IF @QuestionType NOT IN ('MCQ', 'T/F', 'Text')
        BEGIN
            RAISERROR('Question type must be MCQ, T/F, or Text.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 7: BestAnswer مطلوب دايماً
        -- ==============================================================
        IF @BestAnswer IS NULL OR LEN(TRIM(@BestAnswer)) = 0
        BEGIN
            RAISERROR('BestAnswer is required for all question types.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 8: Points Validation
        -- ==============================================================
        IF @Points IS NULL OR @Points <= 0
        BEGIN
            RAISERROR('Points must be greater than 0.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 9: Type-specific Validations
        -- ==============================================================
        IF @QuestionType = 'T/F'
        BEGIN
            IF @CorrectAnswer IS NULL OR @CorrectAnswer NOT IN ('True', 'False')
            BEGIN
                RAISERROR('For T/F questions, CorrectAnswer must be ''True'' or ''False''.', 16, 1);
                ROLLBACK; RETURN;
            END
        END

        IF @QuestionType = 'MCQ'
        BEGIN
            IF @CorrectAnswer IS NULL OR LEN(TRIM(@CorrectAnswer)) = 0
            BEGIN
                RAISERROR('For MCQ questions, CorrectAnswer is required.', 16, 1);
                ROLLBACK; RETURN;
            END

            IF @OptionsList IS NULL OR LEN(TRIM(@OptionsList)) = 0
            BEGIN
                RAISERROR('For MCQ questions, @OptionsList is required (separated by |).', 16, 1);
                ROLLBACK; RETURN;
            END

            DECLARE @OptionsCount INT = (
                SELECT COUNT(*)
                FROM   STRING_SPLIT(@OptionsList, '|')
                WHERE  LEN(TRIM(value)) > 0
            );

            IF @OptionsCount < 2
            BEGIN
                RAISERROR('MCQ questions must have at least 2 options.', 16, 1);
                ROLLBACK; RETURN;
            END

            IF NOT EXISTS (
                SELECT 1
                FROM   STRING_SPLIT(@OptionsList, '|')
                WHERE  TRIM(value) = TRIM(@CorrectAnswer)
            )
            BEGIN
                RAISERROR('CorrectAnswer must match one of the provided options exactly.', 16, 1);
                ROLLBACK; RETURN;
            END
        END

        IF @QuestionType = 'Text' AND @CorrectAnswer IS NOT NULL
            PRINT 'Note: CorrectAnswer is not used for Text questions.';

        -- ==============================================================
        -- STEP 10: Duplicate Check (باستثناء السؤال نفسه)
        -- ==============================================================
        IF EXISTS (
            SELECT 1 FROM [exams].Question
            WHERE  CourseId     = @CourseId
              AND  QuestionText = @QuestionText
              AND  QuestionId  != @QuestionId
              AND  IsDeleted    = 0
        )
        BEGIN
            RAISERROR('A question with the same text already exists in this course.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 11: لو تغير الـ Type من MCQ → احذف الـ Options القديمة
        --          لو اتغير لـ MCQ → امسح القديم وضيف جديد
        -- ==============================================================
        IF @OldType = 'MCQ' AND @QuestionType != 'MCQ'
        BEGIN
            DECLARE @OldOptionsCount INT = (
                SELECT COUNT(*) FROM [exams].QuestionOption WHERE QuestionId = @QuestionId
            );

            DELETE FROM [exams].QuestionOption WHERE QuestionId = @QuestionId;

            PRINT '⚠ Warning: Type changed from MCQ. '
                + CAST(@OldOptionsCount AS NVARCHAR(10))
                + ' old option(s) removed.';
        END
        ELSE IF @QuestionType = 'MCQ'
        BEGIN
            -- امسح القديم وضيف الجديد (سواء كان MCQ قبل أو لأ)
            DELETE FROM [exams].QuestionOption WHERE QuestionId = @QuestionId;

            INSERT INTO [exams].QuestionOption (QuestionOptionText, QuestionId)
            SELECT TRIM(value), @QuestionId
            FROM   STRING_SPLIT(@OptionsList, '|')
            WHERE  LEN(TRIM(value)) > 0;
        END

        -- ==============================================================
        -- STEP 12: Update Question
        -- ==============================================================
        UPDATE [exams].Question
        SET
            QuestionText  = TRIM(@QuestionText),
            QuestionType  = @QuestionType,
            CorrectAnswer = CASE WHEN @QuestionType = 'Text' THEN NULL ELSE TRIM(@CorrectAnswer) END,
            BestAnswer    = TRIM(@BestAnswer),
            Points        = @Points
        WHERE QuestionId = @QuestionId;

        COMMIT TRANSACTION;
        PRINT 'Question updated successfully. ID = ' + CAST(@QuestionId AS NVARCHAR(10));

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        IF ERROR_NUMBER() = 2627
            RAISERROR('Error: this question already exists.', 16, 1);
        ELSE
        BEGIN
            DECLARE @ErrMsg_Upd NVARCHAR(2000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg_Upd, 16, 1);
        END
    END CATCH
END
GO


-- =====================================================================
--  stp_DeleteQuestion
-- =====================================================================
CREATE OR ALTER PROCEDURE [exams].stp_DeleteQuestion
    @QuestionId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==============================================================
        -- STEP 1: Role Check
        -- ==============================================================
        DECLARE @CurrentInsId INT;

        SELECT @CurrentInsId = I.InsId
        FROM   [userAcc].UserAccount UA
        INNER JOIN [userAcc].Instructor I ON UA.UserId = I.UserId
        WHERE  UA.UserName = SUSER_NAME()
          AND  I.isActive  = 1;

        IF @CurrentInsId IS NULL
        BEGIN
            RAISERROR('Access Denied. Only active instructors can delete questions.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 2: Question Exists + مش محذوف
        -- ==============================================================
        DECLARE @CourseId  INT,
                @IsDeleted BIT,
                @QType     NVARCHAR(20);

        SELECT @CourseId  = CourseId,
               @IsDeleted = IsDeleted,
               @QType     = QuestionType
        FROM   [exams].Question
        WHERE  QuestionId = @QuestionId;

        IF @CourseId IS NULL
        BEGIN
            RAISERROR('Question not found.', 16, 1);
            ROLLBACK; RETURN;
        END

        IF @IsDeleted = 1
        BEGIN
            RAISERROR('Question is already deleted.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 3: Instructor Ownership
        -- ==============================================================
        IF NOT EXISTS (
            SELECT 1 FROM [Courses].CourseInstance
            WHERE  CourseId     = @CourseId
              AND  InstructorId = @CurrentInsId
        )
        BEGIN
            RAISERROR('Access Denied: You do not teach the course this question belongs to.', 16, 1);
            ROLLBACK; RETURN;
        END

        -- ==============================================================
        -- STEP 4: Delete (الـ Trigger يقرر Soft أو Hard)
        -- ==============================================================
        DELETE FROM [exams].Question WHERE QuestionId = @QuestionId;

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
--  trg_SoftDeleteQuestion
-- =====================================================================
CREATE OR ALTER TRIGGER [exams].trg_SoftDeleteQuestion
ON [exams].Question
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- حساب كام سؤال هيتعمله Soft وكام هيتعمله Hard
    DECLARE @SoftCount INT = 0,
            @HardCount INT = 0;

    SELECT @SoftCount = COUNT(*)
    FROM   deleted D
    WHERE  EXISTS (SELECT 1 FROM [exams].ExamQuestion   EQ WHERE EQ.QuestionId = D.QuestionId)
    OR     EXISTS (SELECT 1 FROM [exams].Student_Answer SA WHERE SA.QuestionId = D.QuestionId);

    SELECT @HardCount = COUNT(*)
    FROM   deleted D
    WHERE  NOT EXISTS (SELECT 1 FROM [exams].ExamQuestion   EQ WHERE EQ.QuestionId = D.QuestionId)
    AND    NOT EXISTS (SELECT 1 FROM [exams].Student_Answer SA WHERE SA.QuestionId = D.QuestionId);

    -- Soft Delete: عنده علاقات → IsDeleted = 1
    IF @SoftCount > 0
    BEGIN
        UPDATE Q
        SET    Q.IsDeleted = 1
        FROM   [exams].Question Q
        INNER JOIN deleted D ON Q.QuestionId = D.QuestionId
        WHERE  EXISTS (SELECT 1 FROM [exams].ExamQuestion   EQ WHERE EQ.QuestionId = D.QuestionId)
        OR     EXISTS (SELECT 1 FROM [exams].Student_Answer SA WHERE SA.QuestionId = D.QuestionId);

        PRINT 'Soft Delete applied for '
            + CAST(@SoftCount AS NVARCHAR(10))
            + ' question(s) — has related data, marked as deleted.';
    END

    -- Hard Delete: مفيش علاقات → احذف الـ Options الأول ثم السؤال
    IF @HardCount > 0
    BEGIN
        -- احذف Options أولاً (FK constraint)
        DELETE QO
        FROM   [exams].QuestionOption QO
        INNER JOIN deleted D ON QO.QuestionId = D.QuestionId
        WHERE  NOT EXISTS (SELECT 1 FROM [exams].ExamQuestion   EQ WHERE EQ.QuestionId = D.QuestionId)
        AND    NOT EXISTS (SELECT 1 FROM [exams].Student_Answer SA WHERE SA.QuestionId = D.QuestionId);

        -- ثم احذف السؤال
        DELETE Q
        FROM   [exams].Question Q
        INNER JOIN deleted D ON Q.QuestionId = D.QuestionId
        WHERE  NOT EXISTS (SELECT 1 FROM [exams].ExamQuestion   EQ WHERE EQ.QuestionId = D.QuestionId)
        AND    NOT EXISTS (SELECT 1 FROM [exams].Student_Answer SA WHERE SA.QuestionId = D.QuestionId);

        PRINT 'Hard Delete applied for '
            + CAST(@HardCount AS NVARCHAR(10))
            + ' question(s) — no related data, permanently removed.';
    END
END
GO


-- =====================================================================
--  TEST CASES
-- =====================================================================

-- ── stp_CreateQuestion ───────────────────────────────────────────────

-- Test 1: Valid T/F question (should succeed)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Is SQL a declarative language?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'True',
    @BestAnswer    = 'Yes, SQL is a declarative language',
    @Points        = 1,
    @CourseId      = 1;
GO

-- Test 2: Valid MCQ question with options (should succeed)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Which of the following is a DDL command?',
    @QuestionType  = 'MCQ',
    @CorrectAnswer = 'CREATE',
    @BestAnswer    = 'CREATE is a DDL command used to create database objects',
    @Points        = 2,
    @CourseId      = 1,
    @OptionsList   = 'SELECT|INSERT|CREATE|UPDATE';
GO

-- Test 3: Valid Text question (should succeed)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Explain the difference between DELETE and TRUNCATE in SQL Server.',
    @QuestionType  = 'Text',
    @BestAnswer    = 'DELETE removes rows one by one and can be rolled back; TRUNCATE removes all rows at once and is faster but cannot be rolled back in most cases.',
    @Points        = 5,
    @CourseId      = 1;
GO

-- Test 4: T/F مع CorrectAnswer غلط (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Does SQL Server support stored procedures?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'Yes',       -- مش 'True' أو 'False'
    @BestAnswer    = 'Yes it does',
    @Points        = 1,
    @CourseId      = 1;
GO

-- Test 5: MCQ مع CorrectAnswer مش موجود في الـ Options (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Which keyword is used to filter results in SQL?',
    @QuestionType  = 'MCQ',
    @CorrectAnswer = 'FILTER',    -- مش موجود في الـ Options
    @BestAnswer    = 'WHERE is used to filter',
    @Points        = 2,
    @CourseId      = 1,
    @OptionsList   = 'SELECT|WHERE|HAVING|GROUP BY';
GO

-- Test 6: MCQ مع Option واحد بس (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Which is a SQL aggregate function?',
    @QuestionType  = 'MCQ',
    @CorrectAnswer = 'COUNT',
    @BestAnswer    = 'COUNT is aggregate',
    @Points        = 2,
    @CourseId      = 1,
    @OptionsList   = 'COUNT';     -- أقل من 2 options
GO

-- Test 7: QuestionText أقل من 10 حروف (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Short?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'True',
    @BestAnswer    = 'Some answer',
    @Points        = 1,
    @CourseId      = 1;
GO

-- Test 8: Course مش موجود (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'This is a question for a ghost course?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'True',
    @BestAnswer    = 'True indeed',
    @Points        = 1,
    @CourseId      = 9999;
GO

-- Test 9: Duplicate QuestionText على نفس الـ Course (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'Is SQL a declarative language?',  -- موجود من Test 1
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'True',
    @BestAnswer    = 'Yes',
    @Points        = 1,
    @CourseId      = 1;
GO

-- Test 10: Points = 0 (should fail)
EXEC [exams].stp_CreateQuestion
    @QuestionText  = 'What is a foreign key in databases?',
    @QuestionType  = 'Text',
    @BestAnswer    = 'A foreign key links two tables together',
    @Points        = 0,
    @CourseId      = 1;
GO

-- ── stp_UpdateQuestion ───────────────────────────────────────────────

-- Test 11: Valid update T/F (should succeed)
EXEC [exams].stp_UpdateQuestion
    @QuestionId    = 2,
    @QuestionText  = 'Does a Primary Key allow NULL values?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'False',
    @BestAnswer    = 'No, Primary Key does not allow NULL values',
    @Points        = 1;
GO

-- Test 12: تغيير النوع من T/F لـ MCQ (should succeed + add options)
EXEC [exams].stp_UpdateQuestion
    @QuestionId    = 2,
    @QuestionText  = 'Which statement about Primary Keys is correct?',
    @QuestionType  = 'MCQ',
    @CorrectAnswer = 'It cannot be NULL',
    @BestAnswer    = 'Primary Key uniquely identifies each row and cannot be NULL',
    @Points        = 2,
    @OptionsList   = 'It allows duplicates|It can be NULL|It cannot be NULL|It is optional';
GO

-- Test 13: تغيير النوع من MCQ لـ Text (should succeed + warning: options removed)
EXEC [exams].stp_UpdateQuestion
    @QuestionId    = 2,
    @QuestionText  = 'Explain the concept of a Primary Key in SQL Server.',
    @QuestionType  = 'Text',
    @BestAnswer    = 'A Primary Key uniquely identifies each record in a table and cannot be NULL or duplicate.',
    @Points        = 5;
GO

-- Test 14: Question not found (should fail)
EXEC [exams].stp_UpdateQuestion
    @QuestionId    = 9999,
    @QuestionText  = 'Does this question exist?',
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'False',
    @BestAnswer    = 'No it does not',
    @Points        = 1;
GO

-- Test 15: Duplicate QuestionText (should fail)
EXEC [exams].stp_UpdateQuestion
    @QuestionId    = 3,
    @QuestionText  = 'Is SQL a declarative language?',   -- موجود في QuestionId = (Test 1)
    @QuestionType  = 'T/F',
    @CorrectAnswer = 'True',
    @BestAnswer    = 'Yes',
    @Points        = 1;
GO

-- ── stp_DeleteQuestion ───────────────────────────────────────────────

-- Test 16: Hard Delete - سؤال مش في أي Exam (Trigger → Hard Delete)
-- (افترض QuestionId = 12 مش مضاف لأي Exam)
EXEC [exams].stp_DeleteQuestion @QuestionId = 12;
GO

-- Test 17: Soft Delete - سؤال موجود في ExamQuestion (Trigger → Soft Delete)
EXEC [exams].stp_DeleteQuestion @QuestionId = 1;
GO

-- Test 18: Already soft-deleted (should fail)
EXEC [exams].stp_DeleteQuestion @QuestionId = 1;
GO

-- Test 19: Question not found (should fail)
EXEC [exams].stp_DeleteQuestion @QuestionId = 9999;
GO

SELECT * FROM [exams].Question;
GO
SELECT * FROM [exams].QuestionOption;
GO

