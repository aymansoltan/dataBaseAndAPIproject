use [ExaminationSystemDB]
go

create or alter view [InstructorViews].vw_InstructorProfile

as
    select
        -- personal info
        i.FirstName + ' ' + i.LastName  as FullName,
        i.BirthDate,
        i.Age,
        i.Phone,
        i.InsAddress                    as [Address],
        i.NationalID,
        i.Specialization,
        i.HireDate,
        i.Salary,

        -- account info
        ua.UserName,
        ua.Email,
        ua.createdAt                    as MemberSince,

        -- organization info
        d.DeptName                      as Department,
        b.BranchName

    from   [userAcc].Instructor          i
    inner join [userAcc].UserAccount     ua on i.UserId   = ua.UserId
    inner join [orgnization].Department  d  on i.DeptId   = d.DeptId
    inner join [orgnization].Branch      b  on d.BranchId = b.BranchId

    -- each instructor sees only their own data
    where  ua.UserName = suser_name()
      and  ua.isActive = 1
      and  i.isActive  = 1;
go

---------------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter view [InstructorViews].vw_InstructorCourses 
as
    select
        -- course info
        c.CourseName,
        ci.AcademicYear,

        -- organization info
        t.TrackName,
        it.IntakeName,
        b.BranchName,

        -- number of students in this course instance
        (
            select count(*)
            from   [userAcc].Student s
            where  s.TrackId  = ci.TrackId
              and  s.IntakeId = ci.IntakeId
              and  s.BranchId = ci.BranchId
              and  s.isActive = 1
        )                                           as StudentCount

    from   [userAcc].Instructor          i
    inner join [userAcc].UserAccount     ua on i.UserId             = ua.UserId
    inner join [Courses].CourseInstance  ci on i.InsId              = ci.InstructorId
    inner join [Courses].Course          c  on ci.CourseId          = c.CourseId
    inner join [orgnization].Track       t  on ci.TrackId           = t.TrackId
    inner join [orgnization].Intake      it on ci.IntakeId          = it.IntakeId
    inner join [orgnization].Branch      b  on ci.BranchId          = b.BranchId

    -- each instructor sees only their own courses
    where  ua.UserName =  suser_name()
      and  ua.isActive = 1
      and  i.isActive  = 1
      and  c.isActive  = 1;
go
-----------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter view [InstructorViews].vw_InstructorExams

as
    select
        -- exam info
        e.ExamTitle,
        e.ExamType,

        -- course info
        c.CourseName,
        ci.AcademicYear,

        -- timing
        e.StartTime,
        e.EndTime,
        e.DurationMinutes,

        -- exam status
        case
            when e.IsDeleted = 1                              then 'Cancelled'
            when getdate() < e.StartTime                      then 'Upcoming'
            when getdate() between e.StartTime and e.EndTime  then 'In Progress'
            else                                                   'Ended'
        end                                                   as ExamStatus,

        -- total questions in exam
        (
            select count(*)
            from   [exams].ExamQuestion eq
            where  eq.ExamId = e.ExamId
        )                                                     as TotalQuestions

    from   [userAcc].Instructor          i
    inner join [userAcc].UserAccount     ua on i.UserId             = ua.UserId
    inner join [Courses].CourseInstance  ci on i.InsId              = ci.InstructorId
    inner join [Courses].Course          c  on ci.CourseId          = c.CourseId
    inner join [exams].Exam              e  on ci.CourseInstanceId  = e.CourseInstanceId

    -- each instructor sees only their own exams
    where  ua.UserName =  suser_name()
      and  ua.isActive = 1
      and  i.isActive  = 1;
go

--------------------------------------------------------------

use [ExaminationSystemDB]

go

create or alter procedure [InstructorStp].stp_InstructorStudentResultsPassOrFail
    @Filter nvarchar(10)  -- 'Pass' or 'Fail'
as
begin
    set nocount on;
    begin try

        -- ══════════════════════════════════════════════════════════════
        -- step 1: get current instructor from sql server login
        -- ══════════════════════════════════════════════════════════════
        declare @CurrentInsId int;

        select @CurrentInsId = i.InsId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Instructor i
            on ua.UserId  = i.UserId
           and i.isActive = 1
        where  ua.UserName =  suser_name()
          and  ua.isActive = 1;

        if @CurrentInsId is null
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
            from   [exams].Student_Exam_Result  r
            inner join [exams].Exam             e  on r.ExamId          = e.ExamId
            inner join [Courses].CourseInstance ci on e.CourseInstanceId = ci.CourseInstanceId
            where  ci.InstructorId = @CurrentInsId
              and  e.IsDeleted     = 0
        )
        begin
            print 'No exam results found for your courses yet.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 4: check if results exist for the requested filter
        -- ══════════════════════════════════════════════════════════════
        declare @IsPassed bit = case when @Filter = 'Pass' then 1 else 0 end;

        if not exists (
            select 1
            from   [exams].Student_Exam_Result  r
            inner join [exams].Exam             e  on r.ExamId          = e.ExamId
            inner join [Courses].CourseInstance ci on e.CourseInstanceId = ci.CourseInstanceId
            where  ci.InstructorId = @CurrentInsId
              and  r.IsPassed      = @IsPassed
              and  e.IsDeleted     = 0
        )
        begin
            if @Filter = 'Pass'
                print 'No passed students found in your courses.';
            else
                print 'No failed students found in your courses.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 5: return results
        -- ══════════════════════════════════════════════════════════════
        select
            -- student info
            s.FirstName + ' ' + s.LastName      as StudentName,

            -- exam info
            e.ExamTitle,
            e.ExamType,
            cast(e.StartTime as date)            as ExamDate,

            -- course info
            c.CourseName,
            ci.AcademicYear,

            -- grades
            r.TotalGrade                         as StudentGrade,
            e.TotalGrade                         as ExamTotalGrade,

            -- grade based on course min/max degree
            case
                when r.TotalGrade * 1.0 / e.TotalGrade
                     < c.MinDegree * 1.0 / c.MaxDegree
                then 'Fail'

                when r.TotalGrade * 1.0 / e.TotalGrade
                     < (c.MinDegree * 1.0 / c.MaxDegree) + 0.10
                then 'Pass'

                when r.TotalGrade * 1.0 / e.TotalGrade
                     < (c.MinDegree * 1.0 / c.MaxDegree) + 0.20
                then 'Good'

                when r.TotalGrade * 1.0 / e.TotalGrade
                     < (c.MinDegree * 1.0 / c.MaxDegree) + 0.30
                then 'Very Good'

                else 'Excellent'
            end                                  as Grade

        from   [exams].Student_Exam_Result   r
        inner join [exams].Exam              e  on r.ExamId           = e.ExamId
        inner join [Courses].CourseInstance  ci on e.CourseInstanceId = ci.CourseInstanceId
        inner join [Courses].Course          c  on ci.CourseId        = c.CourseId
        inner join [userAcc].Student         s  on r.StudentId        = s.StudentId

        where  ci.InstructorId = @CurrentInsId
          and  r.IsPassed      = @IsPassed
          and  e.IsDeleted     = 0

        order by c.CourseName, ci.AcademicYear, s.FirstName;

    end try
    begin catch
        declare @ErrMsg nvarchar(2000) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end
go
