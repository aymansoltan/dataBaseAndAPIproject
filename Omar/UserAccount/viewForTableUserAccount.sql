
-- =============================================
-- View 
-- =============================================
CREATE VIEW [userAcc].vw_ShowUserAccounts
AS
SELECT 
    UserId AS [User ID],
    UserName AS [Username],
    Email AS [Email],
    CASE WHEN isActive = 1 THEN 'Active' ELSE 'Inactive' END AS [Status],
    RoleId AS [Role ID]
FROM [userAcc].[UserAccount];
GO
