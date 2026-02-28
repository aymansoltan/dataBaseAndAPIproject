 go
 create view [MangerViews].v_branchsummary
as
select 
    [branchname] as [branch_name], 
    case 
        when [isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    [createdat] as [creation_time]
from [orgnization].[branch];
go

create or alter view [MangerViews].v_department_branch_summary
as
select 
    dept.[deptname] as [department_name],
    case
        when dept.[isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    dept.[createdat] as [creation_time],
    br.[branchname] as [branch_name]
from [orgnization].[department] as dept 
join [orgnization].[branch] as br
    on dept.branchid = br.branchid;
go

create or alter view [MangerViews].v_track_department_branch_details
as
select
    tr.[trackname] as [track_name],
    case
        when tr.[isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    tr.[createdat] as [creation_time],
    dept.[deptname] as [department_name], 
    br.[branchname] as [branch_name]
from [orgnization].[department] as dept 
join [orgnization].[track] as tr
    on dept.deptid = tr.deprtmentid 
join [orgnization].[branch] as br
    on dept.branchid = br.branchid;

go

create or alter view [MangerViews].v_track_Intake_details
as
select 
    ik.[intakename] as [intake_name],
    tr.[trackname] as [track_name],
    case
        when ik.[isactive] = 1 and tr.[isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    tr.[createdat] as [track_creation_time]
from [orgnization].[Track] as tr join [orgnization].[IntakeTrack] as ITr
on tr.[TrackId] = ITr.TrackId join [orgnization].[Intake] as ik
on ITr.IntakeId = ik.[IntakeId]
go

create view [MangerViews].v_orgnizationSummarySchema
as 
select 
    br.[branchname] as [branch_name],
    dept.[deptname] as [department_name],
    tr.[trackname] as [track_name],
    ik.[intakename] as [intake_name],
    case 
        when tr.isactive = 1 then 'active' 
        else 'not active' 
    end as [track_status]
from [orgnization].[branch] as br right join [orgnization].[department] as dept 
    on br.branchid = dept.branchid left join [orgnization].[track] as tr 
    on dept.deptid = tr.deprtmentid left join [orgnization].[intaketrack] as itr 
    on tr.trackid = itr.trackid left join [orgnization].[intake] as ik 
    on itr.intakeid = ik.intakeid;
go
create or alter view [MangerViews].v_org_integrity_check
as
select 
    br.branchname as branch_name,
    count(dept.deptid) as total_departments,
    count(tr.trackid) as total_tracks
from [orgnization].[branch] br
left join [orgnization].[department] dept on br.branchid = dept.branchid
left join [orgnization].[track] tr on dept.deptid = tr.deprtmentid
group by br.branchname;
go
create or alter view [MangerViews].v_active_intake_map
as
select 
    ik.intakename as intake_year,
    tr.trackname as track_name,
    dept.deptname as department
from [orgnization].[intake] ik
join [orgnization].[intaketrack] itr on ik.intakeid = itr.intakeid
join [orgnization].[track] tr on itr.trackid = tr.trackid
join [orgnization].[department] dept on tr.deprtmentid = dept.deptid
where ik.isactive = 1 and tr.isactive = 1;
go
create or alter view [MangerViews].v_numTrackInIntake
as
select
ik.[IntakeName] as[Intake_Name],
count(tr.[TrackId]) as[total_track]
from [orgnization].[Intake] as ik join [orgnization].[IntakeTrack] as itk
on ik.[IntakeId] = itk.[IntakeId] join [orgnization].[Track] as tr
on itk.[TrackId] = tr.[TrackId]
group by ik.[IntakeName]
go
create or alter view [MangerViews].v_intake_growth
as
select 
    ik.intakename,
    count(itr.trackid) as number_of_tracks,
    ik.createdat as start_date
from [orgnization].[intake] ik
left join [orgnization].[intaketrack] itr on ik.intakeid = itr.intakeid
group by ik.intakeid, ik.intakename, ik.createdat;
go
create or alter view [MangerViews].v_student_comprehensive_profile
as
select 
    concat(s.[firstname], ' ', s.[lastname]) as [full_name],
    ua.[username] as [user_name],
    ua.[email] as [user_email],
    r.[rolename] as [role_name],
    s.[gender],
    s.[age],
    s.[nationalid] as [ssn],
    s.[phone] as [phone_number],
    br.[branchname] as [branch_name],
    tr.[trackname] as [track_name],
    ik.[intakename] as [intake_name],
    ua.[createdat] as [account_created_at],
    case 
        when ua.[isactive] = 1 then 'active'
        else 'not active'
    end as [account_status]
from [useracc].[userrole] r 
join [useracc].[useraccount] ua on r.[roleid] = ua.[roleid] 
join [useracc].[student] s on ua.[userid] = s.[userid] 
join [orgnization].[branch] br on s.[branchid] = br.[branchid] 
join [orgnization].[track] tr on s.[trackid] = tr.[trackid] 
join [orgnization].[intake] ik on s.[intakeid] = ik.[intakeid]
where r.[RoleName] ='student'


go
create or alter view [MangerViews].v_instructor_profiles
as
select 
    concat(ins.[firstname], ' ', ins.[lastname]) as [full_name],
    ua.[username] as [user_name],
    ua.[email] as [user_email],
    r.[rolename] as [role_name],
    ins.[age],
    ins.[nationalid] as [ssn],
    ins.[phone] as [phone_number],
    ins.[salary],
    ins.[hiredate],
    ins.[specialization],
    dept.[deptname] as [department_name],
    ua.[createdat] as [account_created_at],
    case 
        when ua.[isactive] = 1 then 'active'
        else 'not active'
    end as [account_status]
from [useracc].[userrole] r 
join [useracc].[useraccount] ua on r.[roleid] = ua.[roleid] 
join [useracc].[instructor] ins on ua.[userid] = ins.[userid]
join [orgnization].[department] dept on ins.[deptid] = dept.[deptid]
where r.[rolename] = 'instructor';
go

create or alter view [MangerViews].v_Student_Courses_Instructore
as
select 
    concat(s.[FirstName], ' ', s.[LastName]) as [Student_Name],
    c.[CourseName] as [Course_Name],
    c.[CourseDescription],
    br.[BranchName] as [Branch],
    tr.[TrackName] as [Track],
    ik.[IntakeName] as [Intake],
    ci.[AcademicYear],
    concat(ins.[FirstName], ' ', ins.[LastName]) as [Instructor_Name]
from [userAcc].[Student] s
join [orgnization].[Branch] br on s.[BranchId] = br.[BranchId]
join [orgnization].[Track] tr on s.[TrackId] = tr.[TrackId]
join [orgnization].[Intake] ik on s.[IntakeId] = ik.[IntakeId]
join [Courses].[CourseInstance] ci 
    on  ci.[BranchId] = s.[BranchId] 
    and ci.[TrackId] = s.[TrackId] 
    and ci.[IntakeId] = s.[IntakeId]
join [Courses].[Course] c on ci.[CourseId] = c.[CourseId]
join [userAcc].[Instructor] ins on ci.[InstructorId] = ins.[InsId];
go


create or alter view [MangerViews].v_question_bank_summary
as
select 
    c.coursename,
    q.questiontype,
    count(q.questionid) as [total_questions],
    avg(q.points) as [average_difficulty_points]
from [exams].question q
join [courses].course c on q.courseid = c.courseid
where q.isdeleted = 0
group by c.coursename, q.questiontype;
go

create or alter view [MangerViews].v_exams_comprehensive_details
as
select 
    ex.[ExamTitle] as [exam_title],
    ex.[ExamType] as [exam_type],
    cr.[CourseName] as [course_name],
    concat(ins.[FirstName], ' ', ins.[LastName]) as [instructor_name], -- Â‰« ÷›‰« «·‹ Alias
    ex.[StartTime] as [start_time],
    ex.[EndTime] as [end_time],
    ex.[DurationMinutes] as [duration_min],
    br.[BranchName] as [branch_name],
    tr.[TrackName] as [track_name],
    ik.[IntakeName] as [intake_name]
from [exams].[Exam] as ex 
join [orgnization].[Branch] as br on ex.[BranchId] = br.[BranchId] 
join [orgnization].[Intake] as ik on ex.[IntakeId] = ik.[IntakeId] 
join [orgnization].[Track] as tr on ex.[TrackId] = tr.[TrackId] 
join [Courses].[CourseInstance] as cri on ex.[CourseInstanceId] = cri.[CourseInstanceId] 
join [Courses].[Course] as cr on cr.[CourseId] = cri.[CourseId] 
join [userAcc].[Instructor] as ins on cri.[InstructorId] = ins.[InsId]
where ex.[IsDeleted] = 0;
go

create or alter view [MangerViews].v_students_final_results
as
select 
    concat(s.[FirstName], ' ', s.[LastName]) as [student_name],
    cr.[CourseName] as [course_name],
    cr.[MinDegree] as [passing_grade],
    cr.[MaxDegree] as [max_grade],
    ser.[TotalGrade] as [student_score],
    case 
        when ser.[IsPassed] = 1 then 'Pass'
        else 'Fail'
    end as [result_status]
from [exams].[Student_Exam_Result] as ser 
join [userAcc].[Student] as s on ser.[StudentId] = s.[StudentId] 
join [exams].[Exam] as ex on ser.[ExamId] = ex.[ExamId] 
join [Courses].[CourseInstance] as ci on ex.[CourseInstanceId] = ci.[CourseInstanceId] 
join [Courses].[Course] as cr on ci.[CourseId] = cr.[CourseId];
go
create or alter proc[TrainingMangerStp].Stp_ViewStudentData 
    @StudentId INT 
as
begin
    SET NOCOUNT ON;

    SELECT 
        s.StudentId,
        CONCAT_WS(' ', s.firstname, s.lastname) AS [full_name],
        ua.username AS [user_name],
        ua.email AS [user_email],
        r.rolename AS [role_name],
        s.gender,
        s.age,
        s.nationalid AS [ssn],
        s.phone AS [phone_number],
        br.branchname AS [branch_name],
        tr.trackname AS [track_name],
        ik.intakename AS [intake_name],
        ua.createdat AS [account_created_at],
        CASE 
            WHEN ua.isactive = 1 THEN 'Active'
            ELSE 'Inactive'
        END AS [account_status]
    FROM [userAcc].[Student] s
     JOIN [userAcc].[UserAccount] ua ON s.UserId = ua.UserId
     JOIN [userAcc].[UserRole] r      ON ua.RoleId = r.RoleId
     JOIN [orgnization].[Branch] br  ON s.BranchId = br.BranchId
     JOIN [orgnization].[Track] tr   ON s.TrackId = tr.TrackId
     JOIN [orgnization].[Intake] ik  ON s.IntakeId = ik.IntakeId
    WHERE s.[StudentId] =@StudentId
END
GO

CREATE OR ALTER PROC [TrainingMangerStp].Stp_ViewinstructoreData 
    @InstructorID INT 
AS
BEGIN
    SET NOCOUNT ON;
    select 
    concat(ins.[firstname], ' ', ins.[lastname]) as [full_name],
    ua.[username] as [user_name],
    ua.[email] as [user_email],
    r.[rolename] as [role_name],
    ins.[age],
    ins.[nationalid] as [ssn],
    ins.[phone] as [phone_number],
    ins.[salary],
    ins.[hiredate],
    ins.[specialization],
    dept.[deptname] as [department_name],
    ua.[createdat] as [account_created_at],
    case 
        when ua.[isactive] = 1 then 'active'
        else 'not active'
    end as [account_status]
from [useracc].[userrole] r 
join [useracc].[useraccount] ua on r.[roleid] = ua.[roleid] 
join [useracc].[instructor] ins on ua.[userid] = ins.[userid]
join [orgnization].[department] dept on ins.[deptid] = dept.[deptid]
where ins.InsId= @InstructorID;
end
go