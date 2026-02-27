------------------------------------------------
----------------Branch--------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_AddBranch @BranchName = 'cairo'
exec [TrainingMangerStp].stp_UpdateBranch @BranchId = 12 ,@BranchName =Alex , @IsActive  = 1
exec [TrainingMangerStp].stp_DeleteBranch @BranchId =12
exec [TrainingMangerStp].stp_ActivateBranch @BranchId =7
--trg
--create trigger [orgnization].trg_SoftDeleteBranch on [orgnization].[Branch]
--create trigger [orgnization].trg_inactivateDepartmentWhenInActiveBranch on [orgnization].[branch] after update
------------------------------------------------
----------------Department----------------------
------------------------------------------------
--Stp

exec [TrainingMangerStp].stp_AddDepartment @Deptname ='Cyber Security', @BranchId =10
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
exec [TrainingMangerStp].stp_AddTrack @TrackName='Ethical Hacking' ,@DeptId =5
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
exec [TrainingMangerStp].stp_UpdateIntake @IntakeId =5 ,@IntakeName ='sssssssss' 
exec [TrainingMangerStp].stp_DeleteIntack @IntakeId =5
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeon [orgnization].[Intake]instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntakeon [orgnization].[Intake]after update
------------------------------------------------
----------------IntakeTrack----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_addIntakeTrack @intakeid =1 ,@trackid=6
exec [TrainingMangerStp].stp_ToggleIntakeTrack @intakeid  ,@trackid ,@status
exec [TrainingMangerStp].stp_DeleteIntakeTrack @intakeid ,@trackid
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeTrackon [orgnization].[IntakeTrack]instead of delete
------------------------------------------------
----------------User----------------------
------------------------------------------------
--Stp
--  ﬂ—Ì  «·√œ„‰
exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Admin',  @password = 'Pass@123', @email = 'admin@exam.com',  @roletype = 'admin';
--  ﬂ—Ì  «·„«‰Ã— (≈‰  ⁄«„· Mapping ·‹ manager ⁄‘«‰ Ì—ÊÕ ·‹ training manager)
exec [TrainingMangerStp].[stp_createsystemuser] @username = 'Mrihan', @password = 'Mrihan@123', @email = 'Mrihan@exam.com', @roletype = 'manager';
exec [TrainingMangerStp].[stp_createsystemuser] 'InstructorOne', 'Inst@123', 'InsOne@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'InstructorTwo', 'Inst@123', 'InsTwo@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'StudentOne', 'Std@123', 'StdOne@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'StudentTwo', 'Std@123', 'StdTwo@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'StudentThree', 'Stu@123', 'StdThree@exam.com', 'student';


exec [TrainingMangerStp].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 
exec [TrainingMangerStp].stp_DeleteUserAccount @UserId 
--trg
--CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccountON [userAcc].[UserAccount]INSTEAD OF DELETE

------------------------------------------------
----------------student------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].[stp_addstudent] @firstname ,@lastname  ,@gender    ,@birthdate ,@stuaddress,@phone,@nationalid,@userid,@branchid,@intakeid,@trackid   
exec [TrainingMangerStp].[stp_updatestudent] @studentid = 1,@stuaddress = '6th of october, giza', @phone = '01122334455';
exec [TrainingMangerStp].[stp_deletestudent] @studentid = 5;
--trg
--create or alter trigger [useracc].[trg_preventdeletestudent]on [useracc].[student]instead of delete
------------------------------------------------
----------------instructor------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_addinstructor 
    @firstname = 'ahmed', 
    @lastname  = 'hassan', 
    @birthdate = '1985-05-20', 
    @insaddress = 'nasr city, cairo', 
    @phone      = '01012345678', 
    @nationalid = '28505201234567', 
    @salary     = 7500.00, 
    @specialization = 'sql server development', 
    @userid     = 6,  
    @deptid     = 1 
    
exec [TrainingMangerStp].stp_updateinstructor 
    @insid = 1,                 -- —ﬁ„ «·„œ—” ›Ì «·ÃœÊ·
    @salary = 9500.50,          -- «·—« » «·ÃœÌœ (·«“„ > 4000)
    @specialization = 'Data Science'; -- «· Œ’’ «·ÃœÌœ

exec [trainingmangerstp].stp_deleteinstructor @instructoid
--trg
--CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor] ON [useracc].[instructor] INSTEAD OF DELETE
---------------------------------------------
--------------VIEWS--------------------------
---------------------------------------------
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



