


EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Inactive Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 2: CourseInstance مش موجود (should fail - رسالة واضحة)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Ghost CI', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 9999, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 3: CourseInstance موجود بس مش بتاعك (should fail - رسالة مختلفة)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Not Mine', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 5, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 4: Branch/Track/Intake مش بيطابق الـ CourseInstance (should fail)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Mismatch Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 99, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 5: Valid Manual Exam (should succeed)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'SQL Final Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-01 09:00', @EndTime = '2026-06-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3,4,5';
GO

-- Test 6: Duplicate Title (should fail)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'SQL Final Exam', @ExamType = 'Regular',
    @StartTime = '2026-07-01 09:00', @EndTime = '2026-07-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,3';
GO

-- Test 7: Duplicate IDs يتجاهلوا (should succeed + note)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Dup IDs Exam', @ExamType = 'Regular',
    @StartTime = '2026-08-01 09:00', @EndTime = '2026-08-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Manual', @QuestionIds = '1,2,2,3,3,3,4';
GO

-- Test 8: Random Total (should succeed)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Random Total', @ExamType = 'Regular',
    @StartTime = '2026-09-01 10:00', @EndTime = '2026-09-01 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @QuestionCount = 5;
GO

-- Test 9: Smart Fill - Text ناقص (should succeed + warnings)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'SmartFill Exam', @ExamType = 'Regular',
    @StartTime = '2026-10-01 09:00', @EndTime = '2026-10-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @MCQCount = 2, @TFCount = 2, @TextCount = 20;
GO

-- Test 10: المجموع أكبر من المتاح (should fail)
EXEC [InstructorStp].stp_CreateExam
    @ExamTitle = 'Impossible', @ExamType = 'Regular',
    @StartTime = '2026-11-01 09:00', @EndTime = '2026-11-01 11:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3,
    @Mode = 'Random', @MCQCount = 999, @TFCount = 999, @TextCount = 999;
GO

-- ── stp_UpdateExam ───────────────────────────────────────────────────

-- Test 11: Valid update (should succeed)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'SQL Final Updated', @ExamType = 'Corrective',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 12: Exam not found (should fail)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 999, @ExamTitle = 'Not Found', @ExamType = 'Regular',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 13: Instructor tries IsDeleted = 1 (should fail)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Try Soft Delete', @ExamType = 'Regular',
    @StartTime = '2026-06-10 10:00', @EndTime = '2026-06-10 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 1;
GO

-- Test 14: Duration > 3 hours (should fail)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Too Long Exam', @ExamType = 'Regular',
    @StartTime = '2026-06-10 09:00', @EndTime = '2026-06-10 14:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 15: Duplicate Title في نفس CourseInstance (should fail)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 2, @ExamTitle = 'SQL Final Updated', @ExamType = 'Regular',
    @StartTime = '2026-06-15 10:00', @EndTime = '2026-06-15 12:00',
    @CourseInstanceId = 1, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- Test 16: تغيير CourseInstance لـ Course تاني (يحذف الأسئلة القديمة + warning)
EXEC [InstructorStp].stp_UpdateExam
    @ExamId = 1, @ExamTitle = 'Course Changed', @ExamType = 'Regular',
    @StartTime = '2026-06-20 10:00', @EndTime = '2026-06-20 12:00',
    @CourseInstanceId = 2, @BranchId = 1, @TrackId = 1, @IntakeId = 3, @IsDeleted = 0;
GO

-- ── stp_DeleteExam ───────────────────────────────────────────────────

-- Test 17: Hard Delete - مفيش علاقات (Trigger → بيطبع "Hard Delete applied")
EXEC [InstructorStp].stp_DeleteExam @ExamId = 5;
GO

-- Test 18: Soft Delete - عنده أسئلة (Trigger → بيطبع "Soft Delete applied")
EXEC [InstructorStp].stp_DeleteExam @ExamId = 1;
GO

-- Test 19: Already soft-deleted (should fail)
EXEC [InstructorStp].stp_DeleteExam @ExamId = 1;
GO

-- Test 20: Not found (should fail)
EXEC [InstructorStp].stp_DeleteExam @ExamId = 999;
GO

-- Test 21: Exam locked قبل ساعة من البدء (should fail)
EXEC [InstructorStp].stp_DeleteExam @ExamId = 3;
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





