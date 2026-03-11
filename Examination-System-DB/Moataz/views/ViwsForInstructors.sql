use [ExaminationSystemDB]
go
create or alter proc [InstructorViews].Stp_GetMyProfile
    @InstructorId int
as
begin
    set nocount on;

    select
        i.FirstName + ' ' + i.LastName as FullName,
        i.BirthDate,
        datediff(year, i.BirthDate, getdate()) as Age,
        i.Phone,
        i.InsAddress as [Address],
        i.NationalID,
        i.Specialization,
        cast(i.HireDate as date) as HireDate,
        i.Salary,
        ua.UserName,
        ua.Email,
        ua.createdAt as MemberSince,
        d.DeptName as Department,
        b.BranchName
    from [userAcc].Instructor i with (nolock)
    inner join [userAcc].UserAccount ua with (nolock) on i.UserId = ua.UserId
    inner join [orgnization].Department d with (nolock) on i.DeptId = d.DeptId
    inner join [orgnization].Branch b with (nolock) on d.BranchId = b.BranchId
    where i.InstructorId = @InstructorId
      and ua.isActive = 1
      and i.isActive = 1;
end
go
---------------------------------------------------------------

use [ExaminationSystemDB]
go

create or alter proc [InstructorViews].Stp_GetInstructorCourses
    @InstructorId int
as
begin
    set nocount on;

    select 
        c.CourseName,
        ci.AcademicYear,
        t.TrackName,
        it.IntakeName,
        b.BranchName,
        (
            select count(*) 
            from [userAcc].Student s with (nolock)
            where s.TrackId  = ci.TrackId 
              and s.IntakeId = ci.IntakeId 
              and s.BranchId = ci.BranchId
              and s.isActive = 1
        ) as StudentCount
    from [userAcc].Instructor i with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) on i.InstructorId = ci.InstructorId
    inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
    inner join [orgnization].Track t with (nolock) on ci.TrackId = t.TrackId
    inner join [orgnization].Intake it with (nolock) on ci.IntakeId = it.IntakeId
    inner join [orgnization].Branch b with (nolock) on ci.BranchId = b.BranchId
    where i.InstructorId = @InstructorId
      and i.isActive = 1
      and c.isActive = 1;
end
go
-----------------------------------------------------------

create or alter proc [InstructorViews].Stp_GetInstructorExams
    @InstructorId int
as
begin
    set nocount on;

    select 
        e.ExamId,
        e.ExamTitle,
        e.ExamType,
        c.CourseName,
        ci.AcademicYear,
        e.StartTime,
        e.EndTime,
        e.DurationMinutes,
        case 
            when e.IsDeleted = 1 then 'Cancelled'
            when getdate() < e.StartTime then 'Upcoming'
            when getdate() between e.StartTime and e.EndTime then 'In Progress'
            else 'Ended'
        end as ExamStatus,
        (
            select count(*) 
            from [exams].ExamQuestion eq with (nolock)
            where eq.ExamId = e.ExamId
        ) as TotalQuestions
    from [userAcc].Instructor i with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) on i.InstructorId = ci.InstructorId -- تأكد من InsId
    inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
    inner join [exams].Exam e with (nolock) on ci.CourseInstanceId = e.CourseInstanceId
    where i.InstructorId = @InstructorId
      and i.isActive = 1
      and e.IsDeleted = 0;
end
go
--------------------------------------------------------------

use [ExaminationSystemDB]

go

create or alter procedure [InstructorStp].stp_InstructorStudentResultsPassOrFail
    @InstructorId int,     
    @Filter varchar(10)   
as
begin
    set nocount on;
    begin try
        
        if @Filter not in ('Pass', 'Fail')
            throw 50105 ,'Invalid filter. Use ''Pass'' or ''Fail'' only.', 1 ;


        declare @IsPassed bit = case when @Filter = 'Pass' then 1 else 0 end;

       
        select
            s.FirstName + ' ' + s.LastName as StudentName,
            e.ExamTitle,
            e.ExamType,
            cast(e.StartTime as date) as ExamDate,
            c.CourseName,
            ci.AcademicYear,
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
        inner join [userAcc].Student s with (nolock) on r.StudentId = s.StudentId
        where ci.InstructorId = @InstructorId
          and r.IsPassed = @IsPassed
          and e.IsDeleted = 0
        order by c.CourseName, ci.AcademicYear, s.FirstName;

    end try
    begin catch
        throw; 
    end catch
end
go