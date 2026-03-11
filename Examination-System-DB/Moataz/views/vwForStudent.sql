create or alter proc [studentViews].Stp_GetStudentProfile
    @StudentId int
as
begin
    set nocount on;

    select 
        s.StudentId,
        concat_ws(' ', s.FirstName, s.LastName) as FullName,
        s.Gender,
        s.BirthDate,
        datediff(year, s.BirthDate, getdate()) as Age,
        s.Phone,
        s.StuAddress as [Address],
        s.NationalID,
        ua.UserName,
        ua.Email,
        ua.createdAt as MemberSince,
        b.BranchName,
        t.TrackName,
        i.IntakeName
    from [userAcc].Student s with (nolock)
    inner join [userAcc].UserAccount ua with (nolock) on s.UserId = ua.UserId
    inner join [orgnization].Branch b with (nolock) on s.BranchId = b.BranchId
    inner join [orgnization].Track t with (nolock) on s.TrackId = t.TrackId
    inner join [orgnization].Intake i with (nolock) on s.IntakeId = i.IntakeId
    where s.StudentId = @StudentId
      and ua.isActive = 1
      and s.isActive = 1;
end
go
-------------------------------------------------------------------------------------------------

create or alter procedure [studentViews].Stp_GetStudentCourses
    @StudentId int
as
begin
    set nocount on;

    select 
        c.CourseName,
        ci.AcademicYear,
        concat_ws(' ', i.FirstName, i.LastName) as InstructorName,
        t.TrackName,
        it.IntakeName
    from [userAcc].Student s with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) 
        on  s.TrackId  = ci.TrackId 
        and s.IntakeId = ci.IntakeId 
        and s.BranchId = ci.BranchId
    inner join [Courses].Course c with (nolock) 
        on ci.CourseId = c.CourseId
    inner join [userAcc].Instructor i with (nolock) 
        on ci.InstructorId = i.InstructorId -- تأكد من اسم العمود InsId
    inner join [orgnization].Track t with (nolock) 
        on ci.TrackId = t.TrackId
    inner join [orgnization].Intake it with (nolock) 
        on ci.IntakeId = it.IntakeId
    where s.StudentId = @StudentId
      and s.isActive = 1
      and c.isActive = 1;
end
go

-------------------------------------------------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter procedure [studentViews].Stp_GetStudentResults
    @StudentId int
as
begin
    set nocount on;

    select 
        e.ExamTitle,
        ci.AcademicYear,
        e.ExamType,
        r.TotalGrade as StudentGrade,
        e.TotalGrade as ExamTotalGrade,
        case 
            when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) 
                 < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) 
            then 'Fail'
            when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) 
                 < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.10 
            then 'Pass'
            when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) 
                 < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.20 
            then 'Good'
            when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) 
                 < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.30 
            then 'Very Good'
            else 'Excellent'
        end as Grade,
        cast(e.StartTime as date) as ExamDate
    from [exams].Student_Exam_Result r with (nolock)
    inner join [exams].Exam e with (nolock) on r.ExamId = e.ExamId
    inner join [Courses].CourseInstance ci with (nolock) on e.CourseInstanceId = ci.CourseInstanceId
    inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
    where r.StudentId = @StudentId
      and e.IsDeleted = 0;
end
go
--------------------------------------------------------------------------------------------------

use [ExaminationSystemDB]
go
create or alter procedure [studentViews].Stp_GetStudentUpcomingExams
    @StudentId int
as
begin
    set nocount on;

    select 
        e.ExamId, 
        e.ExamTitle,
        e.ExamType,
        e.StartTime,
        e.EndTime,
        e.DurationMinutes,
        c.CourseName,
        concat_ws(' ', i.FirstName, i.LastName) as InstructorName
    from [exams].Exam e with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) 
        on e.CourseInstanceId = ci.CourseInstanceId
    inner join [Courses].Course c with (nolock) 
        on ci.CourseId = c.CourseId
    inner join [userAcc].Instructor i with (nolock) 
        on ci.InstructorId = i.InstructorId
    inner join [userAcc].Student s with (nolock) 
        on s.TrackId  = e.TrackId 
        and s.IntakeId = e.IntakeId 
        and s.BranchId = e.BranchId
    where s.StudentId = @StudentId
      and s.isActive = 1
      and e.IsDeleted = 0
      and getdate() < e.StartTime 
    order by e.StartTime asc; 
end
go
-----------------------------------------------------------------------------------

--stp for show exams that fail or pass based on filter
----------------------

use [ExaminationSystemDB]
go
create or alter procedure [StudentStp].stp_StudentExamResultsFailorPass
    @StudentId int,        
    @Filter varchar(10)  
as
begin
    set nocount on;
    begin try
       
        if @Filter not in ('Pass', 'Fail')
            throw 50105 ,'Invalid filter. Use ''Pass'' or ''Fail'' only.', 1 ;


        declare @IsPassed bit = case when @Filter = 'Pass' then 1 else 0 end;

        if not exists (
            select 1 
            from [exams].Student_Exam_Result with (nolock)
            where StudentId = @StudentId and IsPassed = @IsPassed
        )
        begin
            declare @msg nvarchar(100) = 'No ' + @Filter + 'ed exams found.';
            print @msg;
            return;
        end


        select
            e.ExamTitle,
            e.ExamType,
            ci.AcademicYear,
            cast(e.StartTime as date) as ExamDate,
            c.CourseName,
            r.TotalGrade as StudentGrade,
            e.TotalGrade as ExamTotalGrade,
          
            case
                when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0))
                then 'Fail'
                when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.10
                then 'Pass'
                when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.20
                then 'Good'
                when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) < (c.MinDegree * 1.0 / nullif(c.MaxDegree, 0)) + 0.30
                then 'Very Good'
                else 'Excellent'
            end as Grade
        from [exams].Student_Exam_Result r with (nolock)
        inner join [exams].Exam e with (nolock) on r.ExamId = e.ExamId
        inner join [Courses].CourseInstance ci with (nolock) on e.CourseInstanceId = ci.CourseInstanceId
        inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
        where r.StudentId = @StudentId
          and r.IsPassed = @IsPassed
          and e.IsDeleted = 0
        order by e.StartTime desc;

    end try
    begin catch
        throw; 
    end catch
end
go

-------------------------------------------------------------------------------------
 