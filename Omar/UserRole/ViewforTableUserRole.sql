
create view  [userAcc].vw_ShowUserRoles
AS
SELECT 
    RoleId AS [Role ID],
    RoleName AS [Role Name]
FROM [userAcc].[UserRole];
