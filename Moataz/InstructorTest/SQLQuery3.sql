UPDATE [exams].Exam 
SET StartTime = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '08:00:00', 
    EndTime   = CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '11:00:00'
WHERE ExamId = 5;;

SELECT 
    s.StudentId, 
    ua.UserName, 
    ua.UserName,
    s.TrackId, 
    s.BranchId, 
    s.IntakeId
FROM [userAcc].Student s
JOIN [userAcc].UserAccount ua ON s.UserId = ua.UserId
JOIN [exams].Exam e ON s.TrackId = e.TrackId 
                   AND s.BranchId = e.BranchId 
                   AND s.IntakeId = e.IntakeId
WHERE e.ExamId = 5 AND s.IsActive = 1;
SELECT 
    s.StudentId, 
    s.TrackId AS StudentTrack, e.TrackId AS ExamTrack,
    s.BranchId AS StudentBranch, e.BranchId AS ExamBranch,
    s.IntakeId AS StudentIntake, e.IntakeId AS ExamIntake,
    e.StartTime, e.EndTime, GETDATE() AS CurrentServerTime
FROM [userAcc].Student s
CROSS JOIN [exams].Exam e
JOIN [userAcc].UserAccount ua ON s.UserId = ua.UserId
WHERE ua.UserName = 'student_5user' AND e.ExamId = 5;



-- 1.  ﬁ„’ «·‘Œ’Ì…
EXECUTE AS USER = 'student_5user';


BEGIN TRY
    -- ”ƒ«· 1 (T/F)
    EXEC [StudentStp].stp_StudentSubmitAnswer @ExamId = 5, @QuestionId = 1, @StudentResponse = N'true';
    
    -- ”ƒ«· 2 (MCQ)
    EXEC [StudentStp].stp_StudentSubmitAnswer @ExamId = 5, @QuestionId = 2, @StudentResponse = N'theoretically explain the concept';
    
    -- ”ƒ«· 3 (MCQ «··Ì ’·Õ‰«Â)
    EXEC [StudentStp].stp_StudentSubmitAnswer @ExamId = 5, @QuestionId = 3, @StudentResponse = N'option a';
    
    -- ”ƒ«· 4 (T/F)
    EXEC [StudentStp].stp_StudentSubmitAnswer @ExamId = 5, @QuestionId = 4, @StudentResponse = N'true';
    
    -- ”ƒ«· 5 (MCQ)
    EXEC [StudentStp].stp_StudentSubmitAnswer @ExamId = 5, @QuestionId = 5, @StudentResponse = N'option a';

    PRINT 'Student_5user submitted all answers successfully!';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorFromProcedure;
END CATCH

-- 3. «·⁄Êœ… ··√œ„‰
REVERT;
EXECUTE AS USER = 'instructor_1user';

EXEC [InstructorStp].stp_InstructorGradeText
    @ExamId         = 5,
    @StudentId      = 5,
    @QuestionId     = 2,
    @InstructorGrade = 2;

