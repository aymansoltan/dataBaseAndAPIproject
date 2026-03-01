USE [ExaminationSystemDB]
GO

CREATE OR ALTER VIEW [InstructorViews].vw_InstructorDetails
AS
SELECT
    -- بيانات الـ Instructor
    I.InsId,
    I.FirstName,
    I.LastName,
    I.FirstName + ' ' + I.LastName   AS FullName,

    -- بيانات الـ UserAccount
    UA.UserName,
    UA.Email,
    UA.isActive,

    -- بيانات الـ Branch
    B.BranchId,
    B.BranchName,

    -- بيانات الـ Department
    D.DepartmentId,
    D.DepartmentName

FROM        [userAcc].Instructor   I
INNER JOIN  [userAcc].UserAccount  UA ON I.UserId       = UA.UserId
INNER JOIN  [userAcc].Branch       B  ON I.BranchId     = B.BranchId
INNER JOIN  [userAcc].Department   D  ON I.DepartmentId = D.DepartmentId
WHERE       UA.UserName = replace(suser_name(), 'login', 'user')
  AND       UA.isActive = 1;
GO

-----------------------------------------------------------------------


USE [ExaminationSystemDB]
GO

CREATE OR ALTER VIEW [InstructorViews].vw_InstructorMyExams
AS
SELECT
    -- بيانات الـ Instructor
    I.InsId,
    I.FirstName + ' ' + I.LastName   AS InstructorName,
    UA.UserName                       AS InstructorUserName,

    -- بيانات الـ Course
    C.CourseId,
    C.CourseName,
    C.CourseCode,

    -- بيانات الـ CourseInstance
    CI.CourseInstanceId,
    CI.Year,
    CI.Semester,

    -- بيانات الـ Track + Intake + Branch
    T.TrackName,
    IT.IntakeName,
    B.BranchName,

    -- بيانات الـ Exam
    E.ExamId,
    E.ExamType,
    E.StartTime,
    E.EndTime,
    E.TotalGrade,
    E.IsDeleted,

    -- حالة الامتحان
    CASE
        WHEN E.IsDeleted = 1                        THEN 'Cancelled'
        WHEN GETDATE() < E.StartTime                THEN 'Upcoming'
        WHEN GETDATE() BETWEEN E.StartTime
                           AND E.EndTime            THEN 'In Progress'
        ELSE                                             'Ended'
    END AS ExamStatus,

    -- عدد الأسئلة
    (
        SELECT COUNT(*)
        FROM   [exams].ExamQuestion EQ
        WHERE  EQ.ExamId = E.ExamId
    ) AS TotalQuestions,

    -- عدد الطلاب اللي اجوا الامتحان
    (
        SELECT COUNT(DISTINCT SA.StudentId)
        FROM   [exams].Student_Answer SA
        WHERE  SA.ExamId = E.ExamId
    ) AS StudentsAnswered,

    -- عدد الناجحين
    (
        SELECT COUNT(*)
        FROM   [exams].Student_Exam_Result R
        WHERE  R.ExamId  = E.ExamId
          AND  R.IsPassed = 1
    ) AS PassedCount,

    -- عدد الراسبين
    (
        SELECT COUNT(*)
        FROM   [exams].Student_Exam_Result R
        WHERE  R.ExamId  = E.ExamId
          AND  R.IsPassed = 0
    ) AS FailedCount

FROM        [userAcc].UserAccount    UA
INNER JOIN  [userAcc].Instructor     I   ON UA.UserId           = I.UserId
INNER JOIN  [Courses].CourseInstance CI  ON I.InsId             = CI.InstructorId
INNER JOIN  [Courses].Course         C   ON CI.CourseId         = C.CourseId
INNER JOIN  [userAcc].Track          T   ON CI.TrackId          = T.TrackId
INNER JOIN  [userAcc].Intake         IT  ON CI.IntakeId         = IT.IntakeId
INNER JOIN  [userAcc].Branch         B   ON CI.BranchId         = B.BranchId
INNER JOIN  [exams].Exam             E   ON CI.CourseInstanceId = E.CourseInstanceId
WHERE       UA.UserName = replace(suser_name(), 'login', 'user')
  AND       UA.isActive = 1;
GO


-------------------------------------------------------


USE [ExaminationSystemDB]
GO

CREATE OR ALTER VIEW [InstructorViews].vw_InstructorMyCourses
AS
SELECT
    -- بيانات الـ Instructor
    I.InsId,
    I.FirstName + ' ' + I.LastName  AS InstructorName,
    UA.UserName,

    -- بيانات الـ CourseInstance
    CI.CourseInstanceId,
    CI.Year,
    CI.Semester,

    -- بيانات الـ Course
    C.CourseId,
    C.CourseName,
    C.CourseCode,
    C.CreditHours,

    -- بيانات الـ Track + Intake + Branch
    T.TrackId,
    T.TrackName,
    IT.IntakeId,
    IT.IntakeName,
    B.BranchId,
    B.BranchName

FROM        [userAcc].UserAccount    UA
INNER JOIN  [userAcc].Instructor     I   ON UA.UserId           = I.UserId
INNER JOIN  [Courses].CourseInstance CI  ON I.InsId             = CI.InstructorId
INNER JOIN  [Courses].Course         C   ON CI.CourseId         = C.CourseId
INNER JOIN  [userAcc].Track          T   ON CI.TrackId          = T.TrackId
INNER JOIN  [userAcc].Intake         IT  ON CI.IntakeId         = IT.IntakeId
INNER JOIN  [userAcc].Branch         B   ON CI.BranchId         = B.BranchId
WHERE       UA.UserName = replace(suser_name(), 'login', 'user')
  AND       UA.isActive = 1;
GO
--------------------------------------------------------------------------

create or alter procedure [InstructorStp].stp_InstructorExamResultsFailorPass
    @Filter nvarchar(10)  -- 'Pass' or 'Fail'
as
begin
    set nocount on;
    begin try

        -- ══════════════════════════════════════════════════════════════
        -- step 1: get current instructor from sql server login
        -- ══════════════════════════════════════════════════════════════
        declare @CurrentInstructorId int;

        select @CurrentInstructorId = i.InstructorId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Instructor i
            on ua.UserId   = i.UserId
           and i.isActive  = 1
        where  ua.UserName = replace(suser_name(), 'login', 'user')
          and  ua.isActive = 1;

        if @CurrentInstructorId is null
        begin
            raiserror('Access Denied. Only active instructors can view results.', 16, 1);
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 2: validate @Filter value
        -- ══════════════════════════════════════════════════════════════
        if @Filter not in ('Pass', 'Fail')
        begin
            raiserror('Invalid filter. Use ''Pass'' or ''Fail'' only.', 16, 1);
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 3: check if instructor has any exam results at all
        -- ══════════════════════════════════════════════════════════════
        if not exists (
            select 1
            from   [exams].Student_Exam_Result    r
            inner join [exams].Exam               e  on r.ExamId           = e.ExamId
            inner join [Courses].CourseInstance   ci on e.CourseInstanceId = ci.CourseInstanceId
            where  ci.InstructorId = @CurrentInstructorId
              and  e.IsDeleted     = 0
        )
        begin
            print 'No exam results found for your courses.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 4: check if results exist for the requested filter
        -- ══════════════════════════════════════════════════════════════
        declare @IsPassed bit = case when @Filter = 'Pass' then 1 else 0 end;

        if not exists (
            select 1
            from   [exams].Student_Exam_Result    r
            inner join [exams].Exam               e  on r.ExamId           = e.ExamId
            inner join [Courses].CourseInstance   ci on e.CourseInstanceId = ci.CourseInstanceId
            where  ci.InstructorId = @CurrentInstructorId
              and  r.IsPassed      = @IsPassed
              and  e.IsDeleted     = 0
        )
        begin
            if @Filter = 'Pass'
                print 'No students have passed any exams in your courses yet.';
            else
                print 'No students have failed any exams in your courses.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 5: return results
        -- ══════════════════════════════════════════════════════════════
        select
            -- student info
            s.FirstName + ' ' + s.LastName             as StudentName,

            -- exam info
            e.ExamTitle,
            e.ExamType,
            ci.AcademicYear,
            cast(e.StartTime as date)                   as ExamDate,

            -- course info
            c.CourseName,

            -- grades
            r.TotalGrade                                as StudentGrade,
            e.TotalGrade                                as ExamTotalGrade

        from   [exams].Student_Exam_Result    r
        inner join [exams].Exam               e   on r.ExamId           = e.ExamId
        inner join [Courses].CourseInstance   ci  on e.CourseInstanceId = ci.CourseInstanceId
        inner join [Courses].Course           c   on ci.CourseId        = c.CourseId
        inner join [userAcc].Student          s   on r.StudentId        = s.StudentId

        where  ci.InstructorId = @CurrentInstructorId
          and  r.IsPassed      = @IsPassed
          and  e.IsDeleted     = 0

        order by e.StartTime desc;

    end try
    begin catch
        declare @ErrMsg nvarchar(2000) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end
go
