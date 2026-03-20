------------------------------------------
------------question----------------------
------------------------------------------
DECLARE @InsUser NVARCHAR(50);
DECLARE @CourseID INT;
DECLARE @Counter INT;

-- Cursor ··› ⁄·Ï «·„œ—”Ì‰ Ê«·ÌÊ“— ‰Ì„“ » «⁄ Â„
DECLARE ins_cursor CURSOR FOR 
SELECT u.UserName, i.DeptId -- Â‰› —÷ ≈‰ «·ﬂÊ—” ID „—»Êÿ »«·‹ DeptId ·· »”Ìÿ Õ«·Ì«
FROM [userAcc].UserAccount u
JOIN [userAcc].Instructor i ON u.UserId = i.UserId
WHERE u.UserName LIKE 'instructor%';

OPEN ins_cursor;
FETCH NEXT FROM ins_cursor INTO @InsUser, @CourseID; -- Â‰” Œœ„ DeptId ﬂ‹ CourseId „ƒﬁ «

WHILE @@FETCH_STATUS = 0
BEGIN
    -- «‰ Õ«· ‘Œ’Ì… «·„œ—” ⁄‘«‰ «·»—Ê”ÌœÃ— ÌÊ«›ﬁ
    EXECUTE AS USER = @InsUser;

    SET @Counter = 1;
    WHILE @Counter <= 12
    BEGIN
        DECLARE @QText NVARCHAR(MAX) = 'Question Number ' + CAST(@Counter AS NVARCHAR) + ' for Course ' + CAST(@CourseID AS NVARCHAR) + ' - Logical Test';
        
        IF @Counter % 3 = 0 -- √”∆·… MCQ
        BEGIN
            EXEC [InstructorStp].stp_createquestion 
                @questiontext = @QText, @questiontype = 'mcq', @correctanswer = 'option a', 
                @bestanswer = 'this is the most accurate answer', @points = 2, @courseid = @CourseID, 
                @optionslist = 'option a | option b | option c | option d';
        END
        ELSE IF @Counter % 3 = 1 -- √”∆·… T/F
        BEGIN
            EXEC [InstructorStp].stp_createquestion 
                @questiontext = @QText, @questiontype = 't/f', @correctanswer = 'true', 
                @bestanswer = 'fact verified', @points = 1, @courseid = @CourseID, @optionslist = null;
        END
        ELSE -- √”∆·… Text
        BEGIN
            EXEC [InstructorStp].stp_createquestion 
                @questiontext = @QText, @questiontype = 'text', @correctanswer = null, 
                @bestanswer = 'theoretically explain the concept', @points = 5, @courseid = @CourseID, @optionslist = null;
        END

        SET @Counter = @Counter + 1;
    END

    REVERT; -- «·—ÃÊ⁄ ··√œ„‰ ﬁ»· «··›… «·Ã«Ì…
    FETCH NEXT FROM ins_cursor INTO @InsUser, @CourseID;
END

CLOSE ins_cursor;
DEALLOCATE ins_cursor;

-- «· √ﬂœ „‰ ≈Ã„«·Ì «·√”∆·…
SELECT c.CourseName, q.QuestionType, COUNT(*) as TotalQuestions
FROM [exams].[Question] q
JOIN [Courses].[Course] c ON q.CourseId = c.CourseId
GROUP BY c.CourseName, q.QuestionType;

 exec [InstructorStp].stp_updatequestion @questionid    , @questiontext  , @questiontype  , @correctanswer , @bestanswer    , @points        , @optionslist 
 exec [InstructorStp].stp_deletequestion @questionid
 --trg
 --create or alter trigger [exams].trg_softdeletequestion on [exams].questioninstead of delete
------------------------------------------
------------exam--------------------------
------------------------------------------
SELECT definition 
FROM sys.check_constraints 
WHERE name = 'ExamTypeCheck';
--  ﬁ„’ ‘Œ’Ì… «·„œ—”
EXECUTE AS USER = 'instructor_1user';

DECLARE @C_ID INT;
SELECT TOP 1 @C_ID = CourseId FROM [courses].CourseInstance 
WHERE InstructorId = (SELECT InsId FROM [userAcc].Instructor WHERE UserId = (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'instructor_1user'));

-- ≈÷«›… 10 √”∆·… MCQ ”—Ì⁄… ⁄‘«‰ »‰ﬂ «·√”∆·… Ìﬂ›Ì
EXEC [InstructorStp].stp_createquestion 'SQL Indexing - What is a Clustered Index?', 'mcq', 'sorts data rows', 'physical ordering of data in a table', 2, @C_ID, 'sorts data rows | stores nulls | deletes data | creates a view';
EXEC [InstructorStp].stp_createquestion 'SQL Joins - Which join is the default?', 'mcq', 'inner join', 'returns matching rows from both tables', 2, @C_ID, 'inner join | left join | right join | full join';
EXEC [InstructorStp].stp_createquestion 'SQL Constraints - UNIQUE vs Primary Key?', 'mcq', 'unique allows one null', 'unique allows one null while PK allows none', 2, @C_ID, 'unique allows one null | PK allows nulls | both are same | unique is faster';
EXEC [InstructorStp].stp_createquestion 'SQL Functions - What does COUNT(*) do?', 'mcq', 'rows count', 'returns the total number of rows in a table', 2, @C_ID, 'rows count | columns count | sum of values | average values';
EXEC [InstructorStp].stp_createquestion 'SQL Commands - Which is DDL?', 'mcq', 'create', 'Data Definition Language commands like CREATE', 2, @C_ID, 'create | insert | update | delete';
EXEC [InstructorStp].stp_createquestion 'SQL Commands - Which is DML?', 'mcq', 'insert', 'Data Manipulation Language commands like INSERT', 2, @C_ID, 'insert | create | alter | drop';
EXEC [InstructorStp].stp_createquestion 'SQL Operators - LIKE operator purpose?', 'mcq', 'pattern matching', 'searching for a specified pattern in a column', 2, @C_ID, 'pattern matching | exact match | range match | null check';
EXEC [InstructorStp].stp_createquestion 'SQL Views - What is a view?', 'mcq', 'virtual table', 'a virtual table based on the result-set of an SQL statement', 2, @C_ID, 'virtual table | physical table | temporary file | stored procedure';
EXEC [InstructorStp].stp_createquestion 'SQL Sorting - Clause for sorting?', 'mcq', 'order by', 'used to sort the result-set in ascending or descending order', 2, @C_ID, 'order by | group by | sort by | arrange by';
EXEC [InstructorStp].stp_createquestion 'SQL Transactions - What is COMMIT?', 'mcq', 'saves changes', 'permanently saves the changes made during the current transaction', 2, @C_ID, 'saves changes | undoes changes | starts transaction | deletes logs';

REVERT;
EXECUTE AS USER = 'instructor_1user';
DECLARE @C_ID INT = (SELECT TOP 1 CourseId FROM [courses].CourseInstance WHERE InstructorId = (SELECT InsId FROM [userAcc].Instructor WHERE UserId = (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'instructor_1user')));

-- ≈÷«›… √”∆·… T/F (·«“„ correctanswer  ﬂÊ‰ true √Ê false)
EXEC [InstructorStp].stp_createquestion 'SQL is a case-sensitive language by default.', 't/f', 'false', 'SQL keywords are case-insensitive', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'Primary Key can be NULL.', 't/f', 'false', 'Primary Key must be unique and NOT NULL', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'Truncate is a DDL command.', 't/f', 'true', 'TRUNCATE modifies table structure metadata', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'A table can have multiple Foreign Keys.', 't/f', 'true', 'A table can reference multiple tables', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'DELETE command removes the table structure.', 't/f', 'false', 'DELETE only removes data rows', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'Inner Join returns only matching records.', 't/f', 'true', 'Matches based on join condition', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'HAVING clause is used with GROUP BY.', 't/f', 'true', 'Filters groups of data', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'SQL stands for Structured Query Language.', 't/f', 'true', 'Standard name', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'Stored Procedures can return values.', 't/f', 'true', 'Can use output parameters or return codes', 1, @C_ID;
EXEC [InstructorStp].stp_createquestion 'Distinct keyword is used to find unique values.', 't/f', 'true', 'Removes duplicates from results', 1, @C_ID;
REVERT;
-- 1.  ﬁ„’ ‘Œ’Ì… «·„œ—”
-- 1.  ﬁ„’ ‘Œ’Ì… «·„œ—”
EXECUTE AS USER = 'instructor_1user';

DECLARE @CI_ID INT, @B_ID INT, @T_ID INT, @I_ID INT, @C_ID INT;
DECLARE @QIds NVARCHAR(MAX);

-- Ã·» »Ì«‰«  «·ﬂÊ—” Ê«·›—⁄ Ê«· —«ﬂ «··Ì «·„œ—” œÂ „ ”ﬂ‰ ⁄·ÌÂ„
SELECT TOP 1 
    @CI_ID = ci.CourseInstanceId, 
    @B_ID = ci.BranchId, 
    @T_ID = ci.TrackId, 
    @I_ID = ci.IntakeId,
    @C_ID = ci.CourseId
FROM [courses].CourseInstance ci
WHERE ci.InstructorId = (SELECT InsId FROM [userAcc].Instructor WHERE UserId = (SELECT UserId FROM [userAcc].UserAccount WHERE UserName = 'instructor_1user'));

--  Ã„Ì⁄ «·‹ IDs ·√”∆·… «·„«‰ÌÊ«· (√Ê· 5 √”∆·… MCQ ··ﬂÊ—” œÂ)
SELECT @QIds = STRING_AGG(CAST(QuestionId AS NVARCHAR), ',') 
FROM (SELECT TOP 5 QuestionId FROM [exams].Question WHERE CourseId = @C_ID AND IsDeleted = 0) AS t;

IF @CI_ID IS NOT NULL AND @QIds IS NOT NULL
BEGIN
   
    EXEC [InstructorStp].stp_createexam 
        @examtitle = 'SQL Core - Random', 
        @examtype = 'Regular', 
        @starttime = '2026-03-06 13:00:00', 
        @endtime = '2026-03-06 14:30:00',
        @courseinstanceid = @CI_ID, @branchid = @B_ID, @trackid = @T_ID, @intakeid = @I_ID,
        @mode = 'random', @questioncount = 10, @mcqcount = 5, @tfcount = 5;

    -- «„ Õ«‰ 3: Corrective (·· Ã—»…)
    EXEC [InstructorStp].stp_createexam 
        @examtitle = 'SQL Recovery Exam', 
        @examtype = 'Corrective', 
        @starttime = '2026-03-10 10:00:00', 
        @endtime = '2026-03-10 12:00:00',
        @courseinstanceid = @CI_ID, @branchid = @B_ID, @trackid = @T_ID, @intakeid = @I_ID,
        @mode = 'random', @questioncount = 10, @mcqcount = 5, @tfcount = 5;
END
ELSE
    PRINT 'Check: No questions found for this course or instructor is not assigned.';

REVERT; -- —ÃÊ⁄ ··√œ„‰
exec [InstructorStp].stp_updateexam @examid           , @examtitle        , @examtype         , @starttime        , @endtime          , @courseinstanceid , @branchid         , @trackid          , @intakeid         , @isdeleted        
exec [InstructorStp].stp_deleteexam @examid
--create or alter trigger [exams].trg_softdeleteexa on [exams].exam instead of delete
