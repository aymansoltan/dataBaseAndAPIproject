create or alter view [MangerViews].v_branchsummary
as
select 
    [BranchId] as [branch_id],
    lower([branchname]) as [branch_name], 
    case 
        when [isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    [createdat] as [creation_time]
from [orgnization].[branch] with (nolock)
where [isDeleted] =0
go
-----------------------------------------------
create or alter view [MangerViews].v_department_branch_summary
as
select 
    dept.[DeptId],
    br.[BranchId],
    dept.[deptname] as [department_name],
    case 
        when dept.[isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    dept.[createdat] as [creation_time],
    br.[branchname] as [branch_name]
from [orgnization].[department] as dept with (nolock)
inner join [orgnization].[branch] as br with (nolock)
    on dept.branchid = br.branchid
    where dept.[isDeleted] =0 and br.isDeleted = 0;
go
-----------------------------------------------------
create or alter view [MangerViews].v_track_department_branch_details
as
select 
    tr.[TrackId],            
    dept.[DeptId],           
    br.[BranchId],          
    tr.[trackname] as [track_name],
    case 
        when tr.[isactive] = 1 and dept.[isactive] = 1 and br.[isactive] = 1 then 'active'
        else 'not active'
    end as [status],
    tr.[createdat] as [creation_time],
    dept.[deptname] as [department_name], 
    br.[branchname] as [branch_name]
from [orgnization].[track] as tr with (nolock)
inner join [orgnization].[department] as dept with (nolock)
    on tr.deprtmentid = dept.deptid 
inner join [orgnization].[branch] as br with (nolock)
    on dept.branchid = br.branchid
where tr.isDeleted = 0 
  and dept.isDeleted = 0 
  and br.isDeleted = 0;
go-----------------------------------------------------------
create or alter view [MangerViews].v_track_intake_details
as
select 
    ITr.[IntakeId],         
    ITr.[TrackId],          
    ik.[intakename] as [intake_name],
    tr.[trackname] as [track_name],
    case 
        when ik.[isactive] = 1 and tr.[isactive] = 1 and ITr.[isactive] = 1 then 'active'
        else 'not active'
    end as [overall_status],
    tr.[createdat] as [track_creation_time],
    ik.[isactive] as [is_intake_active], 
    tr.[isactive] as [is_track_active],
    ITr.[isactive] as [is_link_active] 
from [orgnization].[Track] as tr with (nolock)
inner join [orgnization].[IntakeTrack] as ITr with (nolock)
    on tr.[TrackId] = ITr.TrackId
inner join [orgnization].[Intake] as ik with (nolock)
    on ITr.IntakeId = ik.[IntakeId]
where tr.isDeleted = 0 
  and ik.isDeleted = 0; 
go
--------------------------------------------------------
create or alter view [MangerViews].v_orgnizationSummarySchema
as 
select 
    br.[BranchId],
    dept.[DeptId],
    tr.[TrackId],
    ik.[IntakeId],
    isnull(br.[branchname], 'No Branch') as [branch_name],
    isnull(dept.[deptname], 'No Department') as [department_name],
    isnull(tr.[trackname], 'No Track') as [track_name],
    isnull(ik.[intakename], 'No Intake') as [intake_name],
    case 
        when tr.isactive = 1 and br.isactive = 1 then 'Active' 
        else 'Not Active' 
    end as [track_status]
from [orgnization].[branch] as br with (nolock)
left join [orgnization].[department] as dept with (nolock)
    on br.branchid = dept.branchid and dept.isDeleted = 0
left join [orgnization].[track] as tr with (nolock)
    on dept.deptid = tr.deprtmentid and tr.isDeleted = 0
left join [orgnization].[intaketrack] as itr with (nolock)
    on tr.trackid = itr.trackid and itr.isactive = 1
left join [orgnization].[intake] as ik with (nolock)
    on itr.intakeid = ik.intakeid and ik.isDeleted = 0
where br.isDeleted = 0;
go
-------------------------------------------------
create or alter view [MangerViews].v_org_integrity_check
as
select 
    br.[BranchId], 
    br.BranchName as [branch_name],
    count(distinct case when dept.isDeleted = 0 then dept.DeptId end) as [total_departments],
    count(distinct case when tr.isDeleted = 0 and dept.isDeleted = 0 then tr.TrackId end) as [total_tracks],
    count(distinct case when itr.isactive = 1 and tr.isDeleted = 0 then itr.IntakeId end) as [total_active_intakes]

from [orgnization].[Branch] br with (nolock)
left join [orgnization].[Department] dept with (nolock) 
    on br.BranchId = dept.BranchId
left join [orgnization].[Track] tr with (nolock) 
    on dept.DeptId = tr.DeprtmentId
left join [orgnization].[IntakeTrack] itr with (nolock) 
    on tr.TrackId = itr.TrackId

where br.isDeleted = 0
group by br.BranchId, br.BranchName;
go
----------------------------------------------------
create or alter view [MangerViews].v_active_intake_map
as
select 
    ik.[IntakeId],         
    tr.[TrackId],            
    br.[BranchId],           
    ik.intakename as [intake_year],
    tr.trackname as [track_name],
    dept.deptname as [department],
    br.branchname as [branch_name],
    itr.isactive as [link_status]
from [orgnization].[intake] ik with (nolock)
inner join [orgnization].[intaketrack] itr with (nolock) 
    on ik.intakeid = itr.intakeid
inner join [orgnization].[track] tr with (nolock) 
    on itr.trackid = tr.trackid
inner join [orgnization].[department] dept with (nolock) 
    on tr.deprtmentid = dept.deptid
inner join [orgnization].[branch] br with (nolock) 
    on dept.branchid = br.branchid
where ik.isactive = 1 
  and tr.isactive = 1 
  and itr.isactive = 1      
  and ik.isDeleted = 0 
  and tr.isDeleted = 0 
  and br.isDeleted = 0;    
go
-----------------------------------------------------
create or alter view [MangerViews].v_intake_growth
as
select 
    ik.[IntakeId],
    ik.[IntakeName] as [intake_name],
    count(distinct itr.[TrackId]) as [number_of_tracks],
    cast(ik.createdat as date) as [start_date]
from [orgnization].[Intake] ik with (nolock)
left join [orgnization].[IntakeTrack] itr with (nolock) 
    on ik.IntakeId = itr.IntakeId and itr.isactive = 1 
where ik.isDeleted = 0
group by ik.[IntakeId], ik.[IntakeName], cast(ik.createdat as date);
go
----------------------------------------------------
create or alter view [MangerViews].v_student_comprehensive_profile
as
select 
    s.[StudentId],        
    ua.[UserId],         
    s.[BranchId],         
    s.[TrackId],          
    concat(s.[firstname], ' ', s.[lastname]) as [full_name],
    ua.[username] as [user_name],
    ua.[email] as [user_email],
    r.[rolename] as [role_name],
    s.[gender],
    (0 + Convert(Char(8),GetDate(),112) - Convert(Char(8),s.[BirthDate],112)) / 10000 as [age], 
    s.[nationalid] as [ssn],
    s.[phone] as [phone_number],
    br.[branchname] as [branch_name],
    tr.[trackname] as [track_name],
    ik.[intakename] as [intake_name],
    ua.[createdat] as [account_created_at],
    case 
        when ua.[isactive] = 1 and s.[isDeleted] = 0 then 'active'
        else 'not active'
    end as [account_status]
from [useracc].[useraccount] ua with (nolock)
inner join [useracc].[userrole] r with (nolock) 
    on r.[roleid] = ua.[roleid] 
inner join [useracc].[student] s with (nolock) 
    on ua.[userid] = s.[userid] 
inner join [orgnization].[branch] br with (nolock) 
    on s.[branchid] = br.[branchid] 
inner join [orgnization].[track] tr with (nolock) 
    on s.[trackid] = tr.[trackid] 
inner join [orgnization].[intake] ik with (nolock) 
    on s.[intakeid] = ik.[intakeid]
where r.[rolename] = 'Student' 
  and ua.isDeleted = 0; 
go
-----------------------------------------------------
create or alter view [MangerViews].v_instructor_profiles
as
select 
    concat(ins.[firstname], ' ', ins.[lastname]) as [full_name],
    ua.[username] as [user_name],
    ua.[email] as [user_email],
    r.[rolename] as [role_name],
   
    datediff(year, ins.[BirthDate], getdate()) as [age],
    ins.[nationalid] as [ssn],
    ins.[phone] as [phone_number],
    ins.[salary],
    cast(ins.[hiredate] as date) as [hire_date],
    ins.[specialization],
    dept.[deptname] as [department_name],
    ua.[createdat] as [account_created_at],
    case 
        when ua.[isactive] = 1 then 'active'
        else 'not active'
    end as [account_status]
from [useracc].[userrole] r with (nolock)
inner join [useracc].[useraccount] ua with (nolock) 
    on r.[roleid] = ua.[roleid] 
inner join [useracc].[instructor] ins with (nolock) 
    on ua.[userid] = ins.[userid]
inner join [orgnization].[department] dept with (nolock) 
    on ins.[deptid] = dept.[deptid]
where r.[rolename] = 'instructor';
go----------------------------------------------------
create or alter view [MangerViews].v_student_courses_instructor
as
select 
    s.[StudentId],
    c.[CourseId],
    ci.InstructorId,         
    
    concat(s.[firstname], ' ', s.[lastname]) as [student_name],
    c.[coursename] as [course_name],
    c.[coursedescription],
    br.[branchname] as [branch],
    tr.[trackname] as [track],
    ik.[intakename] as [intake],
    ci.[academicyear],
    concat(ins.[firstname], ' ', ins.[lastname]) as [instructor_name],
    
    ci.[IsActive] as [is_course_active]
    
from [userAcc].[student] s with (nolock)
inner join [orgnization].[branch] br with (nolock) 
    on s.[branchid] = br.[branchid]
inner join [orgnization].[track] tr with (nolock) 
    on s.[trackid] = tr.[trackid]
inner join [orgnization].[intake] ik with (nolock) 
    on s.[intakeid] = ik.[intakeid]
inner join [courses].[courseinstance] ci with (nolock) 
    on  ci.[branchid] = s.[branchid] 
    and ci.[trackid] = s.[trackid] 
    and ci.[intakeid] = s.[intakeid]
inner join [courses].[course] c with (nolock) 
    on ci.[courseid] = c.[courseid]
inner join [userAcc].[instructor] ins with (nolock) 
    on ci.[instructorid] = ins.[instructorid]
where s.isDeleted = 0 
  and ci.isDeleted = 0 
  and c.isDeleted = 0; 
go
----------------------------------------------------
create or alter view [MangerViews].v_question_bank_summary
as
select 
    c.[CourseId],          
    c.coursename as [course_name],
    q.questiontype as [question_type],
    count(q.questionid) as [total_questions],
    round(avg(cast(q.points as float)), 2) as [average_points],
    
    sum(q.points) as [total_points_available] 

from [exams].[question] q with (nolock)
inner join [courses].[course] c with (nolock) 
    on q.courseid = c.courseid
where q.isdeleted = 0 
  and c.isdeleted = 0          
group by c.CourseId, c.coursename, q.questiontype;
go
-------------------------------------------------------
create or alter view [MangerViews].v_exams_comprehensive_details
as
select 
    ex.[ExamId],              
    ex.[CourseInstanceId],      
    ex.[BranchId],            
    ex.[TrackId], 
    ex.[IntakeId],
    ex.[ExamTitle] as [exam_title],
    ex.[ExamType] as [exam_type],
    cr.[CourseName] as [course_name],
    concat(ins.[FirstName], ' ', ins.[LastName]) as [instructor_name],
    ex.[StartTime] as [start_time],
    ex.[EndTime] as [end_time],
    ex.[DurationMinutes] as [duration_min],
    br.[BranchName] as [branch_name],
    tr.[TrackName] as [track_name],
    ik.[IntakeName] as [intake_name],
    case 
        when getdate() < ex.[StartTime] then 'Upcoming'
        when getdate() between ex.[StartTime] and ex.[EndTime] then 'Ongoing'
        else 'Finished'
    end as [exam_status]
from [exams].[Exam] as ex with (nolock)
inner join [orgnization].[Branch] as br with (nolock) on ex.[BranchId] = br.[BranchId] 
inner join [orgnization].[Intake] as ik with (nolock) on ex.[IntakeId] = ik.[IntakeId] 
inner join [orgnization].[Track] as tr with (nolock) on ex.[TrackId] = tr.[TrackId] 
inner join [Courses].[CourseInstance] as cri with (nolock) on ex.[CourseInstanceId] = cri.CourseInstanceId
inner join [Courses].[Course] as cr with (nolock) on cr.[CourseId] = cri.[CourseId] 
inner join [userAcc].[Instructor] as ins with (nolock) on cri.[InstructorId] = ins.InstructorId
where ex.[IsDeleted] = 0 
  and br.[IsDeleted] = 0 
  and tr.[IsDeleted] = 0; 
go
------------------------------------------------------
create or alter view [MangerViews].v_students_final_results
as
select 
    s.[StudentId],
    ser.[ExamId],
    ci.CourseInstanceId,         
    s.[BranchId],            
    s.[TrackId],              
    
    concat(s.[FirstName], ' ', s.[LastName]) as [student_name],
    cr.[CourseName] as [course_name],
    cr.[MinDegree] as [passing_grade],
    cr.[MaxDegree] as [max_grade],
    ser.[TotalGrade] as [student_score],
    
    round((cast(ser.[TotalGrade] as float) / nullif(cast(cr.[MaxDegree] as float), 0)) * 100, 2) as [percentage],
    
    case 
        when ser.[IsPassed] = 1 then 'Pass'
        else 'Fail'
    end as [result_status],
    
    cast(ex.[StartTime] as date) as [exam_date]

from [exams].[Student_Exam_Result] as ser with (nolock)
inner join [userAcc].[Student] as s with (nolock) on ser.[StudentId] = s.[StudentId] 
inner join [exams].[Exam] as ex with (nolock) on ser.[ExamId] = ex.[ExamId] 
inner join [Courses].[CourseInstance] as ci with (nolock) on ex.[CourseInstanceId] = ci.CourseInstanceId 
inner join [Courses].[Course] as cr with (nolock) on ci.[CourseId] = cr.[CourseId]
where s.isDeleted = 0 and ex.isDeleted = 0; 
go
go---------------------------------------------
create or alter proc [TrainingMangerStp].Stp_ViewStudentData 
    @StudentId INT 
as
begin
    set nocount on;

    declare @Exists int;

    select 
        s.StudentId,
        concat_ws(' ', s.firstname, s.lastname) as [full_name],
        ua.username as [user_name],
        ua.email as [user_email],
        r.rolename as [role_name],
        s.gender,
        (0 + Convert(Char(8),GetDate(),112) - Convert(Char(8),s.[BirthDate],112)) / 10000 as [age],  
        s.nationalid as [ssn],
        s.phone as [phone_number],
        br.branchname as [branch_name],
        tr.trackname as [track_name],
        ik.intakename as [intake_name],
        ua.createdat as [account_created_at],
        case 
            when ua.isactive = 1 and s.isDeleted = 0 then 'Active'
            else 'Inactive'
        end as [account_status]
    from [userAcc].[Student] s with (nolock)
    inner join [userAcc].[UserAccount] ua with (nolock) on s.UserId = ua.UserId
    inner join [userAcc].[UserRole] r with (nolock)      on ua.RoleId = r.RoleId
    inner join [orgnization].[Branch] br with (nolock)  on s.BranchId = br.BranchId
    inner join [orgnization].[Track] tr with (nolock)   on s.TrackId = tr.TrackId
    inner join [orgnization].[Intake] ik with (nolock)  on s.IntakeId = ik.IntakeId
    where s.[StudentId] = @StudentId 
      and s.[isDeleted] = 0; 
   
    if @@ROWCOUNT = 0
        throw 50100, 'Student not found or has been deleted.', 1;
end
go
----------------------------------------------------
create or alter proc [TrainingMangerStp].Stp_ViewInstructorData 
    @InstructorID INT 
as
begin
    set nocount on;

    select 
        ins.[InstructorId],
        concat_ws(' ', ins.[firstname], ins.[lastname]) as [full_name],
        ua.[username] as [user_name],
        ua.[email] as [user_email],
        r.[rolename] as [role_name],
        (0 + Convert(Char(8),GetDate(),112) - Convert(Char(8),ins.[BirthDate],112)) / 10000 as [age],  
        ins.[nationalid] as [ssn],
        ins.[phone] as [phone_number],
        ins.[salary],
        cast(ins.[hiredate] as date) as [hire_date],
        ins.[specialization],
        dept.[deptname] as [department_name],
        ua.[createdat] as [account_created_at],
        case 
            when ua.[isactive] = 1 and ins.[isDeleted] = 0 then 'active'
            else 'not active'
        end as [account_status]
    from [useracc].[useraccount] ua with (nolock)
    inner join [useracc].[userrole] r with (nolock) 
        on r.[roleid] = ua.[roleid] 
    inner join [useracc].[instructor] ins with (nolock) 
        on ua.[userid] = ins.[userid]
    inner join [orgnization].[department] dept with (nolock) 
        on ins.[deptid] = dept.[deptid]
    where ins.[InstructorId] = @InstructorID 
      and ins.[isDeleted] = 0; 

    if @@ROWCOUNT = 0
        throw 50101, 'Instructor not found or has been deleted from the system', 1;
end
go