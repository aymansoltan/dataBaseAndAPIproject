use [ExaminationSystemDB]

create view [orgnization].vw_Department_Summary
as
select 
    d.deptid as 'department id',
    d.deptname as 'department name',
    b.branchname as 'branch name',
    case
        when d.isActive = 1 then 'active' 
        else 'inactive' 
    end as 'department status',

    (select count(*) from [orgnization].[track] t where t.[DeprtmentId] = d.DeptId) as 'total tracks',
    (select count(*) from [userAcc].[Instructor] i where i.DeptId = d.DeptId) as 'total instructors'
from [orgnization].[Department] d
join [orgnization].[Branch] b on d.BranchId = b.BranchId;