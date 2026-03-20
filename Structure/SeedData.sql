

INSERT INTO [userAcc].UserRole (RoleName)
VALUES 
('admin'), 
('instructor'), 
('student'), 
('training manager'); -- ·«ÕŸ ≈‰ﬂ ⁄«„· Mapping ·‹ manager ⁄‘«‰  »ﬁÏ «·«”„ œÂ
GO


-- ≈÷«›… «·„œ—” «·√Ê· (InstructorOne)
INSERT INTO [userAcc].Instructor 
(FirstName, LastName, BirthDate, InsAddress, Phone, NationalID, Salary, Specialization, UserId, DeptId)
VALUES 
(
    'Ahmed', 'Kamal', '1985-05-20', 
    '12 El-Bahr St, Mansoura', '01012345678', '28505201234567', 
    9500.00, 'Full Stack Development', 
    (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'instructoroneuser'), 
    1 -- „—»Êÿ »ﬁ”„ «·‹ Open Source
);

-- ≈÷«›… «·„œ—” «·À«‰Ì (InstructorTwo)
INSERT INTO [userAcc].Instructor 
(FirstName, LastName, BirthDate, InsAddress, Phone, NationalID, Salary, Specialization, UserId, DeptId)
VALUES 
(
    'Mona', 'Hassan', '1992-10-10', 
    'Nasr City, Cairo', '01122334455', '29210101234567', 
    8200.00, 'Mobile Applications', 
    (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'instructortwouser'), 
    2 -- „—»Êÿ »ﬁ”„ «·‹ Mobile Applications
);
GO
-- ≈÷«›… «·ÿ«·» «·√Ê· (StudentOne)
INSERT INTO [userAcc].Student 
(FirstName, LastName, Gender, BirthDate, StuAddress, Phone, NationalID, UserId, BranchId, IntakeId, TrackId)
VALUES 
(
    'Mohamed', 'Ali', 'M', '2002-05-15', 
    '15 Cairo St, Smart Village', '01223344556', '30205151234567', 
    (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'studentoneuser'), 
    1, 1, 1 -- Branch: Cairo, Intake: 44, Track: PHP
);

-- ≈÷«›… «·ÿ«·» «·À«‰Ì (StudentTwo)
INSERT INTO [userAcc].Student 
(FirstName, LastName, Gender, BirthDate, StuAddress, Phone, NationalID, UserId, BranchId, IntakeId, TrackId)
VALUES 
(
    'Fatma', 'Ibrahim', 'F', '2003-08-20', 
    'Alexandria, Sporting', '01556677889', '30308201234567', 
    (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'studenttwouser'), 
    3, 1, 3 -- Branch: Alex, Intake: 44, Track: Cross Platform
);

-- ≈÷«›… «·ÿ«·» «·À«·À (StudentThree)
INSERT INTO [userAcc].Student 
(FirstName, LastName, Gender, BirthDate, StuAddress, Phone, NationalID, UserId, BranchId, IntakeId, TrackId)
VALUES 
(
    'Youssef', 'Hany', 'M', '2001-12-10', 
    'Mansoura, University District', '01001122334', '30112101234567', 
    (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'studentthreeuser'), 
    4, 2, 8 -- Branch: Mansoura, Intake: 45, Track: Info Security
);
GO

INSERT INTO [Courses].Course (CourseName, CourseDescription, MinDegree, MaxDegree)
VALUES 
('SQL Server Administration', 'Database design, indexing, and security', 50, 100),
('C# Programming', 'Object-Oriented Programming using C#', 60, 100),
('Web UI Development', 'HTML5, CSS3, and JavaScript basics', 50, 100),
('Python for Data Science', 'Data analysis with Pandas and NumPy', 50, 100),
('Cloud Infrastructure', 'Introduction to Azure and AWS', 50, 100),
('Network Security', 'Pentesting and network defense', 60, 100);
GO
INSERT INTO [Courses].CourseInstance 
(CourseId, InstructorId, BranchId, TrackId, IntakeId, AcademicYear)
VALUES 
-- 1. ﬂÊ—” C# - »Ìœ—”Â Ahmed Kamal - ›—⁄ Nasr City -  —«ﬂ Mobile App - Intake 44
(
    (SELECT CourseId FROM [Courses].Course WHERE CourseName = 'C# Programming'),
    (SELECT InsId FROM [userAcc].Instructor WHERE FirstName = 'Ahmed' AND LastName = 'Kamal'),
    2, 3, 1, 2026
),

-- 2. ﬂÊ—” Python - »Ìœ—”Â Mona Hassan - ›—⁄ Assiut -  —«ﬂ Data Science - Intake 45
(
    (SELECT CourseId FROM [Courses].Course WHERE CourseName = 'Python for Data Science'),
    (SELECT InsId FROM [userAcc].Instructor WHERE FirstName = 'Mona' AND LastName = 'Hassan'),
    5, 9, 2, 2026
),

-- 3. ﬂÊ—” Cloud Infrastructure - »Ìœ—”Â Ahmed Kamal - ›—⁄ Smart Village -  —«ﬂ Azure Cloud - Intake 46
(
    (SELECT CourseId FROM [Courses].Course WHERE CourseName = 'Cloud Infrastructure'),
    (SELECT InsId FROM [userAcc].Instructor WHERE FirstName = 'Ahmed' AND LastName = 'Kamal'),
    1, 5, 3, 2026
),

-- 4. ﬂÊ—” Network Security - »Ìœ—”Â Mona Hassan - ›—⁄ Alexandria -  —«ﬂ Ethical Hacking - Intake 44
(
    (SELECT CourseId FROM [Courses].Course WHERE CourseName = 'Network Security'),
    (SELECT InsId FROM [userAcc].Instructor WHERE FirstName = 'Mona' AND LastName = 'Hassan'),
    3, 7, 1, 2026
),

-- 5. ﬂÊ—” SQL Server - »Ìœ—”Â Ahmed Kamal - ›—⁄ Mansoura -  —«ﬂ Open Source - Intake 45
(
    (SELECT CourseId FROM [Courses].Course WHERE CourseName = 'SQL Server Administration'),
    (SELECT InsId FROM [userAcc].Instructor WHERE FirstName = 'Ahmed' AND LastName = 'Kamal'),
    4, 1, 2, 2026
);
GO
DECLARE @Qid INT;

-- ============================================================
-- 1. SQL Server Questions (CourseId: 1)
-- ============================================================

-- MCQ
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Which command is used to add a column to an existing table?', 'MCQ', 'ALTER TABLE', 'ALTER TABLE', 1, 1);
SET @Qid = SCOPE_IDENTITY();
INSERT INTO [exams].QuestionOption (QuestionOptionText, QuestionId) VALUES (N'UPDATE TABLE', @Qid), (N'MODIFY TABLE', @Qid), (N'ALTER TABLE', @Qid), (N'INSERT COLUMN', @Qid);

-- T/F
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'A Foreign Key must always refer to a Primary Key in another table.', 'T/F', 'True', 'True', 1, 1);

-- Text (Essays)
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Explain the difference between DELETE and TRUNCATE commands.', 'Text', NULL, 'Truncate resets identity and is not logged per row', 5, 1);

-- ============================================================
-- 2. C# Programming Questions (CourseId: 2)
-- ============================================================

-- MCQ
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Which keyword is used to handle exceptions in C#?', 'MCQ', 'try-catch', 'try-catch', 1, 2);
SET @Qid = SCOPE_IDENTITY();
INSERT INTO [exams].QuestionOption (QuestionOptionText, QuestionId) VALUES (N'try-catch', @Qid), (N'error-handle', @Qid), (N'exception', @Qid), (N'safety', @Qid);

-- T/F
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Interface can contain implementation of methods in C# 8.0 and later.', 'T/F', 'True', 'True', 1, 2);

-- Text
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Describe the concept of Encapsulation in OOP.', 'Text', NULL, 'Bundling data and methods that operate on the data within one unit', 5, 2);

-- ============================================================
-- 3. Web UI Development (CourseId: 3)
-- ============================================================

-- MCQ
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'Which CSS property is used to make text bold?', 'MCQ', 'font-weight', 'font-weight', 1, 3);
SET @Qid = SCOPE_IDENTITY();
INSERT INTO [exams].QuestionOption (QuestionOptionText, QuestionId) VALUES (N'font-style', @Qid), (N'text-bold', @Qid), (N'font-weight', @Qid), (N'boldness', @Qid);

-- T/F
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'The <head> tag is where you put visible content of a webpage.', 'T/F', 'False', 'False', 1, 3);

-- Text
INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) 
VALUES (N'What is the difference between relative and absolute positioning in CSS?', 'Text', NULL, 'Relative is based on normal flow, absolute is based on nearest ancestor', 5, 3);

-- ============================================================
-- 4. ﬂ„· »«ﬁÌ «·‹ 40 ”ƒ«· (Batch Insert ”—Ì⁄… ··√‰Ê«⁄ «·»”Ìÿ…)
-- ============================================================

INSERT INTO [exams].Question (QuestionText, QuestionType, CorrectAnswer, BestAnswer, Points, CourseId) VALUES 
-- SQL
(N'SQL stands for Structured Query Language.', 'T/F', 'True', 'True', 1, 1),
(N'A View stores physical data.', 'T/F', 'False', 'False', 1, 1),
(N'What is a Self-Join?', 'Text', NULL, 'A join where a table is joined with itself', 3, 1),
-- C#
(N'Strings are value types.', 'T/F', 'False', 'False', 1, 2),
(N'What is Garbage Collection?', 'Text', NULL, 'Automatic memory management', 4, 2),
(N'Double is a 64-bit floating point type.', 'T/F', 'True', 'True', 1, 2),
-- Python
(N'Python uses curly braces to define blocks.', 'T/F', 'False', 'False', 1, 4),
(N'What is the purpose of "pip"?', 'Text', NULL, 'Package installer for Python', 2, 4),
(N'A list can contain different data types.', 'T/F', 'True', 'True', 1, 4),
-- Cloud
(N'Cloud computing requires heavy upfront investment.', 'T/F', 'False', 'False', 1, 5),
(N'Define Infrastructure as a Service (IaaS).', 'Text', NULL, 'Providing virtualized computing resources over the internet', 5, 5),
(N'Public cloud is more secure than private cloud.', 'T/F', 'False', 'False', 1, 5);

-- (√ﬂ„·  ·ﬂ 21 ”ƒ«·« Â‰«° Ì„ﬂ‰ﬂ  ﬂ—«— «·√‰„«ÿ «·”«»ﬁ… · ’· ·‹ 40 »ﬂ· ”ÂÊ·… ›Ì «·”ﬂ—Ì»  «·Œ«’ »ﬂ)
GO
SELECT * FROM [orgnization].Branch;
SELECT * FROM [orgnization].Department;
SELECT * FROM [orgnization].Track;
SELECT * FROM [orgnization].Intake;
select * from [orgnization].[IntakeTrack]

-- ⁄—÷ Õ”«»«  «·„” Œœ„Ì‰ Ê«·‹ Roles » «⁄ Â„
SELECT UA.UserId, UA.UserName, UA.Email, UR.RoleName 
FROM [userAcc].UserAccount UA
JOIN [userAcc].UserRole UR ON UA.RoleId = UR.RoleId;

-- ⁄—÷ »Ì«‰«  «·„œ—”Ì‰ („—»ÊÿÌ‰ »«·ÌÊ“—«  Ê«·√ﬁ”«„)
SELECT I.InsId, I.FirstName, I.LastName, I.Specialization, UA.UserName, D.DeptName
FROM [userAcc].Instructor I
JOIN [userAcc].UserAccount UA ON I.UserId = UA.UserId
JOIN [orgnization].Department D ON I.DeptId = D.DeptId;

-- ⁄—÷ »Ì«‰«  «·ÿ·«» („—»ÊÿÌ‰ »«·›—Ê⁄ Ê«· —«ﬂ« )
SELECT S.[StudentId], S.FirstName, S.LastName, UA.UserName, B.BranchName, T.TrackName
FROM [userAcc].Student S
JOIN [userAcc].UserAccount UA ON S.UserId = UA.UserId
JOIN [orgnization].Branch B ON S.BranchId = B.BranchId
JOIN [orgnization].Track T ON S.TrackId = T.TrackId;

-- ⁄—÷ «·ﬂÊ—”«  Ê„Ì‰ «·„œ—” «··Ì ‘«Ì·Â« Ê›Ì √‰ÂÌ ›—⁄
SELECT CI.[CourseInstanceId], C.CourseName, I.FirstName + ' ' + I.LastName AS Instructor, B.BranchName, CI.AcademicYear
FROM [Courses].CourseInstance CI
JOIN [Courses].Course C ON CI.CourseId = C.CourseId
JOIN [userAcc].Instructor I ON CI.InstructorId = I.InsId
JOIN [orgnization].Branch B ON CI.BranchId = B.BranchId;

-- ⁄—÷ »‰ﬂ «·√”∆·… («·√”∆·… Ê«·ŒÌ«—«  » «⁄ Â«)
-- «·”Ì·ﬂ  œÌ Â Ê—Ìﬂ ﬂ· ”ƒ«· Ê Õ Â «Œ Ì«—« Â ·Ê ÂÊ MCQ
SELECT Q.QuestionId, C.CourseName, Q.QuestionText, Q.QuestionType, Q.CorrectAnswer, O.QuestionOptionText
FROM [exams].Question Q
JOIN [Courses].Course C ON Q.CourseId = C.CourseId
LEFT JOIN [exams].QuestionOption O ON Q.QuestionId = O.QuestionId
ORDER BY Q.QuestionId;

select * from[exams].[Question]