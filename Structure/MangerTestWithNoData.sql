
INSERT INTO [userAcc].UserRole (RoleName)
VALUES 
('admin'), 
('instructor'), 
('student'), 
('training manager'); 
GO
execute as user ='Moatzuser'
------------------------------------------------
----------------Branch--------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_AddBranch @BranchName = 'cairo'
------------------------------------------------------------
exec [TrainingMangerStp].stp_AddBranch @BranchName = 'Alex'
--------------------------------------------------------------
exec [TrainingMangerStp].stp_UpdateBranch @BranchId = 1,@BranchName ='assuit' , @IsActive  = 1
exec [TrainingMangerStp].stp_DeleteBranch @BranchId =1
exec [TrainingMangerStp].stp_ActivateBranch @BranchId =1
--trg
--create trigger [orgnization].trg_SoftDeleteBranch on [orgnization].[Branch]
--create trigger [orgnization].trg_inactivateDepartmentWhenInActiveBranch on [orgnization].[branch] after update
------------------------------------------------
----------------Department----------------------
------------------------------------------------
--Stp

exec [TrainingMangerStp].stp_AddDepartment @Deptname ='Full Stack', @BranchId =1
--------------------------------------------------------------
-------------------
---------

exec [TrainingMangerStp].stp_AddDepartment @Deptname ='Computer Science', @BranchId =2
--------------------------------------------------------------

exec [TrainingMangerStp].stp_UpdateDepartment @DeptId =1 , @DeptName='Full Stack' ,@BranchId =1
exec [TrainingMangerStp].stp_DeleteDepartment @DeptId =2

--trg
--create trigger [orgnization].trg_CheckBranchStatusBeforeInsert on [orgnization].[Department] after insert
--create trigger [orgnization].trg_SoftDeleteDepartment on [orgnization].[Department]instead of delete
--create trigger [orgnization].trg_inactivateTracksWhenInActiveDerpartment on [orgnization].[Department] after update
------------------------------------------------
----------------Track----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_AddTrack @TrackName='.NET' ,@DeptId =1
--------------------------------------------------------------

exec [TrainingMangerStp].stp_AddTrack @TrackName='Network' ,@DeptId =2
--------------------------------------------------------------

exec [TrainingMangerStp].stp_AddTrack @TrackName='Mern' ,@DeptId =1

exec [TrainingMangerStp].stp_UpdateTrack @TrackId =1 ,@TrackName ='Full Stack .NET' ,@DeptId =1
exec [TrainingMangerStp].stp_DeleteTrack @trackid =5

--trg
--create trigger [orgnization].trg_SoftDeleteTrackon [orgnization].[Track] instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveTrackon [orgnization].[Track]after update
------------------------------------------------
----------------Intake----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_AddIntake @IntakeName='Intake 46'
----------------------------------------------------------------
exec [TrainingMangerStp].stp_AddIntake @IntakeName='Intake 47'
----------------------------------------------------------------
exec [TrainingMangerStp].stp_UpdateIntake @IntakeId =5 ,@IntakeName ='sssssssss' 
exec [TrainingMangerStp].stp_DeleteIntack @IntakeId =5
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeon [orgnization].[Intake]instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntakeon [orgnization].[Intake]after update
------------------------------------------------
----------------IntakeTrack----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_addIntakeTrack @intakeid =1 ,@trackid=1
-------------------------------------------------------------
exec [TrainingMangerStp].stp_addIntakeTrack @intakeid =2 ,@trackid=3
----------------------------------------------------------------
exec [TrainingMangerStp].stp_addIntakeTrack @intakeid =1 ,@trackid=2

exec [TrainingMangerStp].stp_ToggleIntakeTrack @intakeid  ,@trackid ,@status
exec [TrainingMangerStp].stp_DeleteIntakeTrack @intakeid ,@trackid
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeTrackon [orgnization].[IntakeTrack]instead of delete
------------------------------------------------
----------------User----------------------
------------------------------------------------
--Stp

exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Admin',  @password = 'Pass@123', @email = 'admin@exam.com',  @roletype = 'admin';
exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Mrihan', @password = 'Mrihan@123', @email = 'Mrihan@exam.com', @roletype = 'manager';
exec [TrainingMangerStp].[stp_createsystemuser] 'Hassan', 'Ins@123', 'Hassan@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'Mariam', 'Ins@123', 'Mariam@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'Moatz', 'Std@123', 'Moatz@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Fady', 'Std@123', 'Fady@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Omar', 'Std@123', 'Omar@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Marco', 'Std@123', 'Marco@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Ragab', 'Std@123', 'Ragab@exam.com', 'student';
--------------------------------------------------------------------------------
exec [TrainingMangerStp].[stp_createsystemuser] 'Hossam', 'Std@123', 'Hossam@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Asmaa', 'Ins@123', 'Asmaa@exam.com', 'instructor';

----------------------------------------------------------------------------------


exec [TrainingMangerStp].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 
exec [TrainingMangerStp].stp_DeleteUserAccount @UserId 
--trg
--CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccountON [userAcc].[UserAccount]INSTEAD OF DELETE

------------------------------------------------
----------------student------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Moatz' ,@lastname='Ahmed'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650211',@nationalid='30108222501474',@userid=5,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Fady' ,@lastname='Sameh'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650214',@nationalid='30108222501476',@userid=6,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Omar' ,@lastname='Kotb'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650213',@nationalid='30108222501477',@userid=7,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Marco' ,@lastname='Samh'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650215',@nationalid='30108222501475',@userid=8,@branchid=1,@intakeid=1,@trackid=2
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Ragab' ,@lastname='Ahmed'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650218',@nationalid='30108222501478',@userid=9,@branchid=1,@intakeid=1,@trackid=2 
--------------------------------------------------------------

exec [TrainingMangerStp].[stp_addstudent] @firstname ='Hossam' ,@lastname='Ahmed'  ,@gender='M'    ,@birthdate='1986-05-20' ,@stuaddress='6th of october, giza',@phone='01146650281',@nationalid='30108222501481',@userid=10,@branchid=2,@intakeid=2,@trackid=3
--------------------------------------------------------------



exec [TrainingMangerStp].[stp_updatestudent] @studentid = 1,@stuaddress = '6th of october, giza', @phone = '01122334455';
exec [TrainingMangerStp].[stp_deletestudent] @studentid = 5;
--trg
--create or alter trigger [useracc].[trg_preventdeletestudent]on [useracc].[student]instead of delete
------------------------------------------------
----------------instructor------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_addinstructor 
    @firstname = 'Hassan', 
    @lastname  = 'Eldash', 
    @birthdate = '1985-05-20', 
    @insaddress = 'nasr city, cairo', 
    @phone      = '01012345678', 
    @nationalid = '28505201234567', 
    @salary     = 7500.00, 
    @specialization = 'JS', 
    @userid     = 3,  
    @deptid     = 1 

    exec [TrainingMangerStp].stp_addinstructor 
    @firstname = 'Mariam', 
    @lastname  = 'Ahmed', 
    @birthdate = '1985-05-20', 
    @insaddress = 'nasr city, cairo', 
    @phone      = '01012345679', 
    @nationalid = '28505201234569', 
    @salary     = 7500.00, 
    @specialization = 'Node js', 
    @userid     = 4,  
    @deptid     = 1 

    ----------------------------------------------
        exec [TrainingMangerStp].stp_addinstructor 
    @firstname = 'Asmaa', 
    @lastname  = 'Ahmed', 
    @birthdate = '1985-05-20', 
    @insaddress = 'nasr city, cairo', 
    @phone      = '01012345611', 
    @nationalid = '28505201234511', 
    @salary     = 7500.00, 
    @specialization = 'Network', 
    @userid     = 11,  
    @deptid     = 2
    
------------------------------------------

exec [TrainingMangerStp].stp_updateinstructor 
    @insid = 1,                 -- ��� ������ �� ������
    @salary = 9500.50,          -- ������ ������ (���� > 4000)
    @specialization = 'Data Science'; -- ������ ������

exec [trainingmangerstp].stp_deleteinstructor @instructoid


--trg
--CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor] ON [useracc].[instructor] INSTEAD OF DELETE
-- Courses--------------
EXEC [TrainingMangerStp].stp_AddCourse 'Web Fundamentals (HTML/CSS)', 100, 50, 'Building responsive web pages';
EXEC [TrainingMangerStp].stp_AddCourse 'JavaScript & ES6', 100, 50, 'Modern JavaScript for Web Development';
EXEC [TrainingMangerStp].stp_AddCourse 'Introduction to Linux', 100, 50, 'Linux Administration and Shell Scripting';
EXEC [TrainingMangerStp].stp_AddCourse 'Cloud Computing (Azure)', 100, 60, 'Deploying and managing cloud resources';
--------------------------------------------------------------
EXEC [TrainingMangerStp].stp_AddCourse 'Network', 100, 60, 'Network netwok';
------------------------------------------------------------
--CourseInstance--------------------
EXEC [TrainingMangerStp].stp_addCourseInstance
    @courseid=1     ,
    @instructorid=1 ,
    @branchid=1     ,
    @trackid=1      ,
    @intakeid=1     ,
    @academicyear=2026 


    EXEC [TrainingMangerStp].stp_addCourseInstance
    @courseid=2     ,
    @instructorid=1 ,
    @branchid=1     ,
    @trackid=1      ,
    @intakeid=1     ,
    @academicyear=2026 

    EXEC [TrainingMangerStp].stp_addCourseInstance
    @courseid=3     ,
    @instructorid=2 ,
    @branchid=1     ,
    @trackid=2      ,
    @intakeid=1     ,
    @academicyear=2026 

      EXEC [TrainingMangerStp].stp_addCourseInstance
    @courseid=4     ,
    @instructorid=2 ,
    @branchid=1     ,
    @trackid=2      ,
    @intakeid=1     ,
    @academicyear=2026 
--------------------------------------------------------
          EXEC [TrainingMangerStp].stp_addCourseInstance
    @courseid=5     ,
    @instructorid=11 ,
    @branchid=2    ,
    @trackid=3      ,
    @intakeid=2     ,
    @academicyear=2026 

------------------------------------------------

---------------------------------------------
--------------VIEWS--------------------------
---------------------------------------------
EXECUTE AS USER = 'mrihanuser';
revert
go
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



