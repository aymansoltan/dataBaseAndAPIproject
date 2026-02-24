-- =============================================
-- View 
-- =============================================
CREATE VIEW [userAcc].vw_ShowInstructors
AS
SELECT 
    i.InsId AS [Instructor ID],
    i.FirstName + ' ' + i.LastName AS [Full Name],
    i.Specialization,
    d.DeptName AS [Department],
    b.BranchName AS [Branch],
    CASE WHEN ua.isActive = 1 THEN 'Active' ELSE 'Inactive' END AS [Status]
FROM [userAcc].[Instructor] i
JOIN [userAcc].[UserAccount] ua ON i.UserId = ua.UserId
JOIN [orgnization].[Department] d ON i.DeptId = d.DeptId
JOIN [orgnization].[Branch] b ON d.BranchId = b.BranchId;
GO