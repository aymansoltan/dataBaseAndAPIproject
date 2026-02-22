use [ExaminationSystemDB]
create view [orgnization].vw_ShowBranch
AS
select 
    [BranchId] as Id ,
    [BranchName] as 'Branch name', 
    case 
        when [isActive] = 1 then 'active'
        else 'not active'
    end as 'status' ,
    [createdAt]
from [orgnization].[Branch]
