

------------------------------------------------------------
-- 5) View
------------------------------------------------------------
CREATE OR ALTER VIEW [userAcc].vw_ShowStudents
AS
SELECT 
    s.StudentId AS [Student ID],
    s.FirstName + ' ' + s.LastName AS [Full Name],
    s.Gender,
    s.Age,
    b.BranchName AS [Branch],
    i.IntakeName AS [Intake],
    t.TrackName AS [Track],
    CASE WHEN ua.isActive = 1 THEN 'Active' ELSE 'Inactive' END AS [Status]
FROM userAcc.Student s
JOIN userAcc.UserAccount ua ON s.UserId = ua.UserId
JOIN orgnization.Branch b ON s.BranchId = b.BranchId
JOIN orgnization.Intake i ON s.IntakeId = i.IntakeId
JOIN orgnization.Track t ON s.TrackId = t.TrackId;
GO