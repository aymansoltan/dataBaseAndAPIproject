------------------------------------------------
----------------Branch--------------------------
------------------------------------------------
--Stp
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Cairo';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Alexandria';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Mansoura';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Assiut';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Tanta';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Minya';
EXEC [TrainingMangerStp].stp_AddBranch @BranchName = 'Ismailia';
select * from [orgnization].[Branch]
------------------------
exec [TrainingMangerStp].stp_UpdateBranch @BranchId = 1 ,@BranchName ='Cairo' , @IsActive =0
exec [TrainingMangerStp].stp_DeleteBranch @BranchId = 1
exec [TrainingMangerStp].stp_ActivateBranch @BranchId =1
--trg
--create trigger [orgnization].trg_SoftDeleteBranch on [orgnization].[Branch]
--create trigger [orgnization].trg_inactivateDepartmentWhenInActiveBranch on [orgnization].[branch] after update
------------------------------------------------
----------------Department----------------------
------------------------------------------------
----Stp
DECLARE @DeptName NVARCHAR(50);
DECLARE @BranchId INT;

-- ﬁ«∆„… «·√ﬁ”«„ «·Œ„”…
DECLARE @Depts TABLE (Name NVARCHAR(50));
INSERT INTO @Depts VALUES 
('Software Development'), 
('Open Source'), 
('Mobile Applications'), 
('Data Science'), 
('Cyber Security');

-- Loop Ì·› ⁄·Ï ﬂ· ›—⁄ „ÊÃÊœ Õ«·Ì«
DECLARE branch_cursor CURSOR FOR 
SELECT BranchId FROM [orgnization].Branch;

OPEN branch_cursor;
FETCH NEXT FROM branch_cursor INTO @BranchId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- ·ﬂ· ›—⁄° ÷Ì› «·‹ 5 √ﬁ”«„
    DECLARE dept_cursor CURSOR FOR SELECT Name FROM @Depts;
    OPEN dept_cursor;
    FETCH NEXT FROM dept_cursor INTO @DeptName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- «” œ⁄«¡ «·»—Ê”ÌœÃ— » «⁄ﬂ
        EXEC [TrainingMangerStp].stp_AddDepartment @DeptName = @DeptName, @BranchId = @BranchId;
        FETCH NEXT FROM dept_cursor INTO @DeptName;
    END

    CLOSE dept_cursor;
    DEALLOCATE dept_cursor;

    FETCH NEXT FROM branch_cursor INTO @BranchId;
END

CLOSE branch_cursor;
DEALLOCATE branch_cursor;

select Dept.DeptName, dept.isActive, br.BranchName , br.isActive
from [orgnization].[Branch] as br join [orgnization].[Department] as dept
on br.BranchId=dept.BranchId
select * from [orgnization].[Department]

exec [TrainingMangerStp].stp_UpdateDepartment @DeptId =3 , @DeptName='cloud' ,@BranchId =8
exec [TrainingMangerStp].stp_DeleteDepartment @DeptId =2

--trg
--create trigger [orgnization].trg_CheckBranchStatusBeforeInsert on [orgnization].[Department] after insert
--create trigger [orgnization].trg_SoftDeleteDepartment on [orgnization].[Department]instead of delete
--create trigger [orgnization].trg_inactivateTracksWhenInActiveDerpartment on [orgnization].[Department] after update
------------------------------------------------
----------------Track----------------------
------------------------------------------------
--Stp

DECLARE @TrackName NVARCHAR(50);
DECLARE @DeptId INT;

-- ﬁ«∆„… «· —«ﬂ«  «·À·«À… «·„ﬁ —Õ… ·ﬂ· ﬁ”„
-- („„ﬂ‰  €Ì— «·√”«„Ì œÌ “Ì „«  Õ»)
DECLARE @Tracks TABLE (Name NVARCHAR(50));
INSERT INTO @Tracks VALUES 
('Full Stack Web Development'), 
('Advanced Technical Skills'), 
('Professional Soft Skills');

-- Loop Ì·› ⁄·Ï ﬂ· «·√ﬁ”«„ «··Ì „ÊÃÊœ… ›Ì ﬂ· «·›—Ê⁄
DECLARE dept_cursor CURSOR FOR 
SELECT DeptId FROM [orgnization].Department;

OPEN dept_cursor;
FETCH NEXT FROM dept_cursor INTO @DeptId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- ·ﬂ· ﬁ”„° ÷Ì› «·‹ 3  —«ﬂ« 
    DECLARE track_cursor CURSOR FOR SELECT Name FROM @Tracks;
    OPEN track_cursor;
    FETCH NEXT FROM track_cursor INTO @TrackName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- «” œ⁄«¡ «·»—Ê”ÌœÃ— » «⁄ﬂ ·≈÷«›… «· —«ﬂ
        EXEC [TrainingMangerStp].stp_AddTrack @TrackName = @TrackName, @DeptId = @DeptId;
        
        FETCH NEXT FROM track_cursor INTO @TrackName;
    END

    CLOSE track_cursor;
    DEALLOCATE track_cursor;

    FETCH NEXT FROM dept_cursor INTO @DeptId;
END

CLOSE dept_cursor;
DEALLOCATE dept_cursor;

SELECT b.BranchName, d.DeptName, COUNT(t.TrackId) as TracksCount
FROM [orgnization].Branch b
JOIN [orgnization].Department d ON b.BranchId = d.BranchId
JOIN [orgnization].Track t ON d.DeptId = t.DeprtmentId
GROUP BY b.BranchName, d.DeptName
ORDER BY b.BranchName;


exec [TrainingMangerStp].stp_UpdateTrack @TrackId =1 ,@TrackName ='Full Stack .NET' ,@DeptId =1
exec [TrainingMangerStp].stp_DeleteTrack @trackid =5

--trg
--create trigger [orgnization].trg_SoftDeleteTrackon [orgnization].[Track] instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveTrackon [orgnization].[Track]after update
------------------------------------------------
----------------Intake----------------------
------------------------------------------------
--Stp
EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = 'Intake 43';
EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = 'Intake 44';
EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = 'Intake 45';
EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = 'Intake 46';
select * from [orgnization].[Intake]

exec [TrainingMangerStp].stp_UpdateIntake @IntakeId = ,@IntakeName =
exec [TrainingMangerStp].stp_DeleteIntack @IntakeId =
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeon [orgnization].[Intake]instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntakeon [orgnization].[Intake]after update
------------------------------------------------
----------------IntakeTrack----------------------
------------------------------------------------
--Stp
DECLARE @IntakeID INT;
DECLARE @IntakeName NVARCHAR(50);

-- Loop Ì·› ⁄·Ï «·‹ Intakes «··Ì ⁄‰œ‰«
DECLARE intake_cursor CURSOR FOR 
SELECT IntakeId, IntakeName FROM [orgnization].Intake;

OPEN intake_cursor;
FETCH NEXT FROM intake_cursor INTO @IntakeID, @IntakeName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- —»ÿ «·‹ Intake »ﬂ· «· —«ﬂ«  „« ⁄œ«  —«ﬂ Ê«Õœ „Œ ·› ·ﬂ· œ›⁄…
    -- ⁄‘«‰ ‰÷„‰ ≈‰ ﬂ· œ›⁄… ‰«ﬁ’… Õ«Ã…
    INSERT INTO [orgnization].IntakeTrack (IntakeId, TrackId)
    SELECT @IntakeID, TrackId 
    FROM [orgnization].Track
    WHERE 
        (@IntakeName = 'Intake 43' AND TrackId % 10 <> 1) OR -- «” À‰«¡ √Ê·  —«ﬂ ›Ì ﬂ· 10
        (@IntakeName = 'Intake 44' AND TrackId % 10 <> 2) OR -- «” À‰«¡  «‰Ì  —«ﬂ
        (@IntakeName = 'Intake 45' AND TrackId % 10 <> 3) OR
        (@IntakeName = 'Intake 46' AND TrackId % 10 <> 4);

    FETCH NEXT FROM intake_cursor INTO @IntakeID, @IntakeName;
END

CLOSE intake_cursor;
DEALLOCATE intake_cursor;

-- ⁄—÷ «·‰ ÌÃ…: ⁄œœ «· —«ﬂ«  «·„ «Õ… ·ﬂ· œ›⁄… («·„›—Ê÷ ÌﬂÊ‰Ê« √ﬁ· „‰ 105)
SELECT i.IntakeName, COUNT(it.TrackId) as AvailableTracks
FROM [orgnization].Intake i
JOIN [orgnization].IntakeTrack it ON i.IntakeId = it.IntakeId
GROUP BY i.IntakeName;

exec [TrainingMangerStp].stp_ToggleIntakeTrack @intakeid  ,@trackid ,@status
exec [TrainingMangerStp].stp_DeleteIntakeTrack @intakeid ,@trackid
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeTrackon [orgnization].[IntakeTrack]instead of delete


INSERT INTO [userAcc].UserRole (RoleName)
VALUES 
('admin'), 
('instructor'), 
('student'), 
('training manager'); -- ·«ÕŸ ≈‰ﬂ ⁄«„· Mapping ·‹ manager ⁄‘«‰  »ﬁÏ «·«”„ œÂ
GO
select * from [userAcc].UserRole
------------------------------------------------
----------------User----------------------
------------------------------------------------
--Stp
--  ﬂ—Ì  «·√œ„‰
exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Admin',  @password = 'Pass@123', @email = 'admin@exam.com',  @roletype = 'admin';
--  ﬂ—Ì  «·„«‰Ã— (≈‰  ⁄«„· Mapping ·‹ manager ⁄‘«‰ Ì—ÊÕ ·‹ training manager)
exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Mrihan', @password = 'Mrihan@123', @email = 'Mrihan@exam.com', @roletype = 'manager';

DECLARE @i INT = 1;
WHILE @i <= 5
BEGIN
    DECLARE @insName NVARCHAR(50) = 'Instructor_' + CAST(@i AS NVARCHAR);
    DECLARE @insEmail NVARCHAR(100) = 'ins' + CAST(@i AS NVARCHAR) + '@exam.com';
    
    EXEC [TrainingMangerStp].[stp_createsystemuser] 
         @username = @insName, 
         @password = 'Inst@123', 
         @email = @insEmail, 
         @roletype = 'instructor';
         
    SET @i = @i + 1;
END

DECLARE @j INT = 1;
WHILE @j <= 20
BEGIN
    DECLARE @stdName NVARCHAR(50) = 'Student_' + CAST(@j AS NVARCHAR);
    DECLARE @stdEmail NVARCHAR(100) = 'std' + CAST(@j AS NVARCHAR) + '@exam.com';
    
    EXEC [TrainingMangerStp].[stp_createsystemuser] 
         @username = @stdName, 
         @password = 'Std@123', 
         @email = @stdEmail, 
         @roletype = 'student';
         
    SET @j = @j + 1;
END
select * from [userAcc].[UserAccount]


exec [TrainingMangerStp].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 
exec [TrainingMangerStp].stp_DeleteUserAccount @UserId 
--trg
--CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccountON [userAcc].[UserAccount]INSTEAD OF DELETE

------------------------------------------------
----------------student------------------------
------------------------------------------------
--Stp
DECLARE @StuUserId INT, @UniqSuffix INT = 1;
DECLARE @BranchId INT, @IntakeId INT, @TrackId INT;

SELECT @IntakeId = IntakeId FROM [orgnization].Intake WHERE IntakeName = 'Intake 46';

DECLARE stu_cursor CURSOR FOR 
SELECT UserId FROM [userAcc].UserAccount WHERE RoleId = (SELECT RoleId FROM [userAcc].UserRole WHERE RoleName = 'student');

OPEN stu_cursor;
FETCH NEXT FROM stu_cursor INTO @StuUserId;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- «Œ Ì«— ›—⁄ Ê —«ﬂ ⁄‘Ê«∆Ì „—»ÊÿÌ‰ »‹ Intake 46
    SELECT TOP 1 @TrackId = it.TrackId, @BranchId = d.BranchId
    FROM [orgnization].IntakeTrack it
    JOIN [orgnization].Track t ON it.TrackId = t.TrackId
    JOIN [orgnization].Department d ON t.DeprtmentId = d.DeptId
    WHERE it.IntakeId = @IntakeId ORDER BY NEWID();

    -- »Ì«‰«  Unique ··„Ê»«Ì· Ê«·ﬁÊ„Ì
    DECLARE @Phone NVARCHAR(20) = '010' + RIGHT('00000000' + CAST(@UniqSuffix AS NVARCHAR), 8);
    DECLARE @NID NVARCHAR(20) = '3000101' + RIGHT('0000000' + CAST(@UniqSuffix AS NVARCHAR), 7);

    EXEC [TrainingMangerStp].[stp_addstudent] 
        @firstname = 'Std_FN', @lastname = 'Std_LN', @gender = 'M', @birthdate = '2000-05-05',
        @stuaddress = 'Student City', @phone = @Phone, @nationalid = @NID, 
        @userid = @StuUserId, @branchid = @BranchId, @intakeid = @IntakeId, @trackid = @TrackId;

    SET @UniqSuffix = @UniqSuffix + 1;
    FETCH NEXT FROM stu_cursor INTO @StuUserId;
END
CLOSE stu_cursor; DEALLOCATE stu_cursor;

select * from [userAcc].[Student]
-- «· √ﬂœ „‰ «· ”ﬂÌ‰


exec [TrainingMangerStp].[stp_updatestudent] @studentid = 1,@stuaddress = '6th of october, giza', @phone = '01122334455';
exec [TrainingMangerStp].[stp_deletestudent] @studentid = 5;
--trg
--create or alter trigger [useracc].[trg_preventdeletestudent]on [useracc].[student]instead of delete
------------------------------------------------
----------------instructor------------------------
------------------------------------------------
--Stp
DECLARE @InsUserId INT;
DECLARE @DeptId INT = 1; -- Â‰»œ√ „‰ √Ê· ﬁ”„
DECLARE @Counter INT = 1;

-- Cursor Ì·› ⁄·Ï «·‹ 5 Õ”«»«  » Ê⁄ «·„œ—”Ì‰ („‰ 3 ·‹ 7)
DECLARE ins_cursor CURSOR FOR 
SELECT UserId FROM [userAcc].UserAccount 
WHERE RoleId = (SELECT RoleId FROM [userAcc].UserRole WHERE RoleName = 'instructor')
AND UserId BETWEEN 3 AND 7; --  ÕœÌœ «·‰ÿ«ﬁ «··Ì ŸÂ— ›Ì ÃœÊ· «·ÌÊ“—“ ⁄‰œﬂ

OPEN ins_cursor;
FETCH NEXT FROM ins_cursor INTO @InsUserId;

WHILE @@FETCH_STATUS = 0
BEGIN
    --  Ê·Ìœ »Ì«‰«  Unique ⁄‘«‰ «·‹ Constraints
    DECLARE @DynamicPhone NVARCHAR(20) = '011' + RIGHT('00000000' + CAST(@Counter AS NVARCHAR), 8);
    DECLARE @DynamicNID NVARCHAR(20) = '2800101' + RIGHT('0000000' + CAST(@Counter AS NVARCHAR), 7);
    DECLARE @FirstName NVARCHAR(50) = 'Ins_First_' + CAST(@Counter AS NVARCHAR);
    DECLARE @LastName NVARCHAR(50) = 'Ins_Last_' + CAST(@Counter AS NVARCHAR);

    --  ‰›Ì– «·»—Ê”ÌœÃ— » «⁄ﬂ
    EXEC [TrainingMangerStp].stp_addinstructor 
        @firstname = @FirstName,
        @lastname = @LastName,
        @birthdate = '1985-01-01',
        @insaddress = 'ITI Branch St',
        @phone = @DynamicPhone,
        @nationalid = @DynamicNID,
        @salary = 9000.00,
        @specialization = 'Technical Instructor',
        @userid = @InsUserId,
        @deptid = @DeptId;

    -- «·«‰ ﬁ«· ··ﬁ”„ «· «·Ì Ê··„œ—” «· «·Ì
    SET @DeptId = @DeptId + 1;
    SET @Counter = @Counter + 1;
    FETCH NEXT FROM ins_cursor INTO @InsUserId;
END

CLOSE ins_cursor;
DEALLOCATE ins_cursor;
select * from[userAcc].Instructor;
-- «· √ﬂœ „‰  ”ﬂÌ‰ «·„œ—”Ì‰ ÊÕ”«» «·”‰ (Age)  ·ﬁ«∆Ì«
SELECT InstructorId, FirstName, Age, Specialization, DeptId 
FROM [userAcc].Instructor;

    
exec [TrainingMangerStp].stp_updateinstructor 
    @insid = 1,                 -- —ﬁ„ «·„œ—” ›Ì «·ÃœÊ·
    @salary = 9500.50,          -- «·—« » «·ÃœÌœ (·«“„ > 4000)
    @specialization = 'Data Science'; -- «· Œ’’ «·ÃœÌœ

exec [trainingmangerstp].stp_deleteinstructor @instructoid
--trg
--CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor] ON [useracc].[instructor] INSTEAD OF DELETE

---------------------------------------------
--------------Course--------------------------
---------------------------------------------
--stp
go

EXEC [TrainingMangerStp].stp_AddCourse 'SQL Server Databases', 100, 50, 'Relational Database Management and T-SQL';
EXEC [TrainingMangerStp].stp_AddCourse 'C# Programming', 100, 50, 'Fundamentals of C# and .NET Framework';
EXEC [TrainingMangerStp].stp_AddCourse 'Web Fundamentals (HTML/CSS)', 100, 50, 'Building responsive web pages';
EXEC [TrainingMangerStp].stp_AddCourse 'JavaScript & ES6', 100, 50, 'Modern JavaScript for Web Development';
EXEC [TrainingMangerStp].stp_AddCourse 'Entity Framework Core', 100, 60, 'Object-Relational Mapping (ORM) for .NET';
EXEC [TrainingMangerStp].stp_AddCourse 'ASP.NET Core MVC', 100, 60, 'Building Server-side Web Applications';
EXEC [TrainingMangerStp].stp_AddCourse 'Python for Data Science', 100, 50, 'Data Analysis and Visualization using Python';
EXEC [TrainingMangerStp].stp_AddCourse 'Introduction to Linux', 100, 50, 'Linux Administration and Shell Scripting';
EXEC [TrainingMangerStp].stp_AddCourse 'Cloud Computing (Azure)', 100, 60, 'Deploying and managing cloud resources';
EXEC [TrainingMangerStp].stp_AddCourse 'Unit Testing (NUnit)', 100, 50, 'Ensuring code quality through automated testing';

-- «· √ﬂœ „‰ ≈÷«›… «·ﬂÊ—”« 
SELECT * FROM [Courses].[Course]
go
exec [TrainingMangerStp].stp_UpdateCourse @CourseId,@CourseName , @MaxDegree  ,@MinDegree  ,@Description ,@IsActive 
exec [TrainingMangerStp].stp_DeleteCourse @CourseId

--trg
--create trigger [courses].trg_Softcoursedelete on [courses].[course] instead of delete
---------------------------------------------
--------------CourseInstance-----------------
---------------------------------------------
DECLARE @CourseID INT;
DECLARE @InstructorID INT;
DECLARE @BranchID INT;
DECLARE @TrackID INT;
DECLARE @IntakeID INT;
DECLARE @AcademicYear INT = 2026; -- «·”‰… «·œ—«”Ì… «·Õ«·Ì…

-- Cursor ·Ã·» ﬂ· «· Ê·Ì›«  (Branch, Track, Intake) «··Ì ›ÌÂ« ÿ·«» ›⁄·«
DECLARE course_instance_cursor CURSOR FOR 
SELECT DISTINCT BranchId, TrackId, IntakeId 
FROM [userAcc].Student;

OPEN course_instance_cursor;
FETCH NEXT FROM course_instance_cursor INTO @BranchID, @TrackID, @IntakeID;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- ·ﬂ· ( —«ﬂ/›—⁄/«‰ Ìﬂ)° Â‰÷Ì› «·‹ 10 ﬂÊ—”«  «··Ì ⁄‰œ‰«
    DECLARE @CourseCounter INT = 1;
    WHILE @CourseCounter <= 10
    BEGIN
        -- «Œ Ì«— ﬂÊ—” „‰ «·‹ 10
        SET @CourseID = (SELECT CourseId FROM (SELECT CourseId, ROW_NUMBER() OVER (ORDER BY CourseId) as rn FROM [Courses].[Course]) t WHERE rn = @CourseCounter);
        
        -- «Œ Ì«— „œ—” ⁄‘Ê«∆Ì „‰ «·‹ 5 «··Ì ⁄‰œ‰« (⁄‘«‰ ‰Ê“⁄ «·Õ„·)
        SET @InstructorID = (SELECT TOP 1[InsId]  FROM [userAcc].Instructor ORDER BY NEWID());

        --  ‰›Ì– «·»—Ê”ÌœÃ— » «⁄ﬂ ·≈‰‘«¡ «·‰”Œ… «·œ—«”Ì…
        EXEC [TrainingMangerStp].stp_addCourseInstance 
            @courseid = @CourseID,
            @instructorid = @InstructorID,
            @branchid = @BranchID,
            @trackid = @TrackID,
            @intakeid = @IntakeID,
            @academicyear = @AcademicYear;

        SET @CourseCounter = @CourseCounter + 1;
    END

    FETCH NEXT FROM course_instance_cursor INTO @BranchID, @TrackID, @IntakeID;
END

CLOSE course_instance_cursor;
DEALLOCATE course_instance_cursor;

-- «· √ﬂœ „‰ √‰ ﬂ·  —«ﬂ »ﬁÏ „⁄«Â ﬂÊ—”« Â
SELECT 
    b.BranchName, t.TrackName, c.CourseName, i.FirstName AS InstructorName
FROM [Courses].[CourseInstance] ci
JOIN [orgnization].Branch b ON ci.BranchId = b.BranchId
JOIN [orgnization].Track t ON ci.TrackId = t.TrackId
JOIN [Courses].Course c ON ci.CourseId = c.CourseId
JOIN [userAcc].Instructor i ON ci.InstructorId = i.InsId;
exec [TrainingMangerStp].stp_updatecourseinstance @instanceid         @courseid     ,       @instructorid ,       @branchid     ,@trackid      ,@intakeid     ,@academicyear 
exec  [TrainingMangerStp].stp_deleteinstance @instanceid
--create  trigger [courses].trg_preventdeleteinstance on [courses].[courseinstance]instead of delete


---------------------------------------------
--------------VIEWS--------------------------
---------------------------------------------

exec [TrainingMangerStp].Stp_ViewinstructoreData @InstructorID =1;
go
exec [TrainingMangerStp].Stp_ViewStudentData @StudentId =1
go
select * from [MangerViews].v_branchsummary
select * from [MangerViews].v_department_branch_summary
select * from [MangerViews].v_track_department_branch_details
select * from [MangerViews].v_track_Intake_details
select * from [MangerViews].v_org_integrity_check
select * from [MangerViews].v_active_intake_map
select * from [MangerViews].v_numTrackInIntake
select * from [MangerViews].v_intake_growth
select * from [MangerViews].v_student_comprehensive_profile
select * from [MangerViews].v_instructor_profiles
select * from [MangerViews].v_Student_Courses_Instructore


select * from [MangerViews].v_question_bank_summary
select * from [MangerViews].v_exams_comprehensive_details
select * from [MangerViews].v_students_final_results
























s



