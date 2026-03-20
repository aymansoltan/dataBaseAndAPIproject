use [ExaminationSystemDB]
go

create or alter proc [InstructorViews].Stp_GetMyProfile
    @InstructorId int
as
begin
    set nocount on;

    select
        i.[InstructorId],
        i.FirstName + ' ' + i.LastName as FullName,
        i.BirthDate,
        (0 + Convert(Char(8),GetDate(),112) - Convert(Char(8),i.[BirthDate],112)) / 10000 as Age,
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
      and i.isDeleted = 0   
      and d.isDeleted = 0; 

    if @@ROWCOUNT = 0
    begin
        throw 50102, 'Profile not found or account is deactivated.', 1;
    end
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
        c.[CourseId],            
        ci.CourseInstanceId,          
        c.CourseName,
        ci.AcademicYear,
        t.TrackName,
        it.IntakeName,
        b.BranchName,
        (
            select count(s.StudentId) 
            from [userAcc].Student s with (nolock)
            where s.TrackId  = ci.TrackId 
              and s.IntakeId = ci.IntakeId 
              and s.BranchId = ci.BranchId
              and s.isDeleted = 0 
              and s.isActive = 1
        ) as StudentCount
    from [userAcc].Instructor i with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) on i.InstructorId = ci.InstructorId
    inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
    inner join [orgnization].Track t with (nolock) on ci.TrackId = t.TrackId
    inner join [orgnization].Intake it with (nolock) on ci.IntakeId = it.IntakeId
    inner join [orgnization].Branch b with (nolock) on ci.BranchId = b.BranchId
    where i.InstructorId = @InstructorId
      and i.isDeleted = 0         
      and ci.isDeleted = 0        
      and c.isDeleted = 0         
      and i.isActive = 1;

   
    if @@ROWCOUNT = 0
    begin
       
        print 'No active courses found for this instructor.';
    end
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
        ) as TotalQuestions,

        (
            select isnull(sum(q.Points), 0)
            from [exams].ExamQuestion eq with (nolock)
            join [exams].Question q on eq.QuestionId = q.QuestionId
            where eq.ExamId = e.ExamId
        ) as TotalExamPoints

    from [userAcc].Instructor i with (nolock)
    inner join [Courses].CourseInstance ci with (nolock) on i.InstructorId = ci.InstructorId 
    inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
    inner join [exams].Exam e with (nolock) on ci.CourseInstanceId = e.CourseInstanceId 
    where i.InstructorId = @InstructorId
      and i.isDeleted = 0  
      and e.IsDeleted = 0  
    order by e.StartTime desc; 
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
                when r.IsPassed = 0 then 'Fail'
                else 
                    case 
                        when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) >= 0.90 then 'Excellent'
                        when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) >= 0.80 then 'Very Good'
                        when (r.TotalGrade * 1.0 / nullif(e.TotalGrade, 0)) >= 0.70 then 'Good'
                        else 'Pass'
                    end
            end as GradeStatus
        from [exams].Student_Exam_Result r with (nolock)
        inner join [exams].Exam e with (nolock) on r.ExamId = e.ExamId
        inner join [Courses].CourseInstance ci with (nolock) on e.CourseInstanceId = ci.CourseInstanceId 
        inner join [Courses].Course c with (nolock) on ci.CourseId = c.CourseId
        inner join [userAcc].Student s with (nolock) on r.StudentId = s.StudentId
        where ci.InstructorId = @InstructorId
          and r.IsPassed = @IsPassed
          and e.IsDeleted = 0
          and s.isDeleted = 0 
        order by c.CourseName, ci.AcademicYear, s.FirstName;

    end try
    begin catch
        throw; 
    end catch
end
go