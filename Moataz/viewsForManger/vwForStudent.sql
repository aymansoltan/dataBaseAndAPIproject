use [ExaminationSystemDB]
go

create or alter view [studentViews].vw_StudentProfile
as
    select
        -- personal info
        s.StudentId,
        s.FirstName + ' ' + s.LastName  as FullName,
        s.Gender,
        s.BirthDate,
        s.Age,
        s.Phone,
        s.StuAddress                    as [Address],
        s.NationalID,

        -- account info
        ua.UserName,
        ua.Email,
        ua.createdAt                    as MemberSince,

        -- organization info
        b.BranchName,
        t.TrackName,
        i.IntakeName

    from   [userAcc].Student            s
    inner join [userAcc].UserAccount    ua on s.UserId   = ua.UserId
    inner join [orgnization].Branch     b  on s.BranchId = b.BranchId
    inner join [orgnization].Track      t  on s.TrackId  = t.TrackId
    inner join [orgnization].Intake     i  on s.IntakeId = i.IntakeId

    -- each student sees only their own data
    where  ua.UserName = suser_name()
      and  ua.isActive = 1
      and  s.isActive  = 1;
go

-------------------------------------------------------------------------------------------------


use [ExaminationSystemDB]
go

create or alter view [studentViews].vw_StudentCourses
as
    select
        -- course info
        c.CourseName,
        ci.AcademicYear,

        -- instructor info
        i.FirstName + ' ' + i.LastName  as InstructorName,

        -- organization info
        t.TrackName,
        it.IntakeName

    from   [userAcc].Student             s
    inner join [userAcc].UserAccount     ua on s.UserId          = ua.UserId
    inner join [Courses].CourseInstance  ci on s.TrackId         = ci.TrackId
                                           and s.IntakeId        = ci.IntakeId
                                           and s.BranchId        = ci.BranchId
    inner join [Courses].Course          c  on ci.CourseId       = c.CourseId
    inner join [userAcc].Instructor      i  on ci.InstructorId   = i.InsId
    inner join [orgnization].Track       t  on ci.TrackId        = t.TrackId
    inner join [orgnization].Intake      it on ci.IntakeId       = it.IntakeId

    where  ua.UserName = suser_name()
      and  ua.isActive = 1
      and  s.isActive  = 1
      and  c.isActive  = 1;
go

-------------------------------------------------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter view [studentViews].vw_StudentExamResults
as
    select
        -- exam info
        e.ExamTitle,
        ci.AcademicYear,
        e.ExamType,

        -- grades
        r.TotalGrade                                as StudentGrade,
        e.TotalGrade                                as ExamTotalGrade,

        -- grade calculation based on course min/max degree
        -- passratio = MinDegree / MaxDegree (e.g. 60/100 = 0.60)
        -- grade bands shift with each course's passing threshold
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
        end                                         as Grade,

        -- exam date
        cast(e.StartTime as date)                   as ExamDate

    from   [exams].Student_Exam_Result   r
    inner join [exams].Exam              e  on r.ExamId          = e.ExamId
    inner join [Courses].CourseInstance  ci on e.CourseInstanceId = ci.CourseInstanceId
    inner join [Courses].Course          c  on ci.CourseId        = c.CourseId
    inner join [userAcc].Student         s  on r.StudentId        = s.StudentId
    inner join [userAcc].UserAccount     ua on s.UserId           = ua.UserId

    where  ua.UserName = suser_name()
      and  ua.isActive = 1
      and  s.isActive  = 1
      and  e.IsDeleted = 0;
go

--------------------------------------------------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter view [studentViews].vw_StudentUpcomingExams
as
    select
        -- exam info
        e.ExamTitle,
        e.ExamType,
        e.StartTime,
        e.EndTime,
        e.DurationMinutes,

        -- course info
        c.CourseName,

        -- instructor info
        i.FirstName + ' ' + i.LastName  as InstructorName

    from   [exams].Exam                  e
    inner join [Courses].CourseInstance  ci on e.CourseInstanceId = ci.CourseInstanceId
    inner join [Courses].Course          c  on ci.CourseId        = c.CourseId
    inner join [userAcc].Instructor      i  on ci.InstructorId    = i.InsId
    inner join [userAcc].Student         s  on s.TrackId          = e.TrackId
                                           and s.IntakeId         = e.IntakeId
                                           and s.BranchId         = e.BranchId
    inner join [userAcc].UserAccount     ua on s.UserId           = ua.UserId

    where  ua.UserName =suser_name()
      and  ua.isActive = 1
      and  s.isActive  = 1
      and  e.IsDeleted = 0
      and  getdate()   < e.StartTime;
go
-----------------------------------------------------------------------------------

--stp for show exams that fail or pass based on filter
----------------------

use [ExaminationSystemDB]
go

create or alter procedure [StudentStp].stp_StudentExamResultsFailorPass
    @Filter nvarchar(10)  -- 'Pass' or 'Fail'
as
begin
    set nocount on;
    begin try

        declare @CurrentStudentId int;

        select @CurrentStudentId = s.StudentId
        from   [userAcc].UserAccount ua
        inner join [userAcc].Student s
            on ua.UserId  = s.UserId
           and s.isActive = 1
        where  ua.UserName = suser_name()
          and  ua.isActive = 1;

        if @CurrentStudentId is null
        begin
            raiserror('Access Denied. Only active students can view results.', 16, 1);
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
        -- step 3: check if student has any exam results at all
        -- ══════════════════════════════════════════════════════════════
        if not exists (
            select 1
            from   [exams].Student_Exam_Result
            where  StudentId = @CurrentStudentId
        )
        begin
            print 'You have not taken any exams yet.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 4: check if results exist for the requested filter
        -- ══════════════════════════════════════════════════════════════
        declare @IsPassed bit = case when @Filter = 'Pass' then 1 else 0 end;

        if not exists (
            select 1
            from   [exams].Student_Exam_Result
            where  StudentId = @CurrentStudentId
              and  IsPassed  = @IsPassed
        )
        begin
            if @Filter = 'Pass'
                print 'You have not passed any exams yet.';
            else
                print 'You have not failed any exams.';
            return;
        end

        -- ══════════════════════════════════════════════════════════════
        -- step 5: return results
        -- ══════════════════════════════════════════════════════════════
        select
            -- exam info
            e.ExamTitle,
            e.ExamType,
            ci.AcademicYear,
            cast(e.StartTime as date)                    as ExamDate,

            -- course info
            c.CourseName,

            -- grades
            r.TotalGrade                                 as StudentGrade,
            e.TotalGrade                                 as ExamTotalGrade,

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
            end                                          as Grade

        from   [exams].Student_Exam_Result   r
        inner join [exams].Exam              e  on r.ExamId           = e.ExamId
        inner join [Courses].CourseInstance  ci on e.CourseInstanceId = ci.CourseInstanceId
        inner join [Courses].Course          c  on ci.CourseId        = c.CourseId

        where  r.StudentId = @CurrentStudentId
          and  r.IsPassed  = @IsPassed
          and  e.IsDeleted = 0

        order by e.StartTime desc;

    end try
    begin catch
        declare @ErrMsg nvarchar(2000) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end
go