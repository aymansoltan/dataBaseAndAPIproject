------------------------------------------------
----------------Branch--------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_AddBranch @BranchName = 'cairo'
exec [TrainingMangerStpTrg].stp_UpdateBranch @BranchId = 12 ,@BranchName =Alex , @IsActive  = 1
exec [TrainingMangerStpTrg].stp_DeleteBranch @BranchId =12
exec [TrainingMangerStpTrg].stp_ActivateBranch @BranchId =7
--trg
--create trigger [orgnization].trg_SoftDeleteBranch on [orgnization].[Branch]
--create trigger [orgnization].trg_inactivateDepartmentWhenInActiveBranch on [orgnization].[branch] after update
------------------------------------------------
----------------Department----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_AddDepartment @Deptname ='Cyber Security', @BranchId =10
exec [TrainingMangerStpTrg].stp_UpdateDepartment @DeptId =3 , @DeptName='cloud' ,@BranchId =8
exec [TrainingMangerStpTrg].stp_DeleteDepartment @DeptId =2

--trg
--create trigger [orgnization].trg_CheckBranchStatusBeforeInsert on [orgnization].[Department] after insert
--create trigger [orgnization].trg_SoftDeleteDepartment on [orgnization].[Department]instead of delete
--create trigger [orgnization].trg_inactivateTracksWhenInActiveDerpartment on [orgnization].[Department] after update
------------------------------------------------
----------------Track----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_AddTrack @TrackName='Ethical Hacking' ,@DeptId =5
exec [TrainingMangerStpTrg].stp_UpdateTrack @TrackId =1 ,@TrackName ='Full Stack .NET' ,@DeptId =1
exec [TrainingMangerStpTrg].stp_DeleteTrack @trackid =5

--trg
--create trigger [orgnization].trg_SoftDeleteTrackon [orgnization].[Track] instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveTrackon [orgnization].[Track]after update
------------------------------------------------
----------------Intake----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_AddIntake @IntakeName='Intake 46'
exec [TrainingMangerStpTrg].stp_UpdateIntake @IntakeId =5 ,@IntakeName ='sssssssss' 
exec [TrainingMangerStpTrg].stp_DeleteIntack @IntakeId =5
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeon [orgnization].[Intake]instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntakeon [orgnization].[Intake]after update
------------------------------------------------
----------------IntakeTrack----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_addIntakeTrack @intakeid =1 ,@trackid=6
exec [TrainingMangerStpTrg].stp_ToggleIntakeTrack @intakeid  ,@trackid ,@status
exec [TrainingMangerStpTrg].stp_DeleteIntakeTrack @intakeid ,@trackid
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeTrackon [orgnization].[IntakeTrack]instead of delete
------------------------------------------------
----------------User----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='admin' ,@password = 'admin@123' , @email = 'admin123@gmail.com',@roletype='admin'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='manager' ,@password = 'man@123' , @email = 'man123@gmail.com',@roletype='manager'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='student1' ,@password = 'stu@123' , @email = 'stu123@gmail.com',@roletype='student'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='student2' ,@password = 'stu@123' , @email = 'stu222@gmail.com',@roletype='student'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='student3' ,@password = 'stu@123' , @email = 'stu333@gmail.com',@roletype='student'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='instructor1' ,@password = 'ins@123' , @email = 'ins123@gmail.com',@roletype='instructor'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='instructor2' ,@password = 'ins@123' , @email = 'ins222@gmail.com',@roletype='instructor'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='instructor3' ,@password = 'ins@123' , @email = 'ins333@gmail.com',@roletype='instructor'
exec [TrainingMangerStpTrg].[sp_createsystemuser] @username ='instructor4' ,@password = 'ins@123' , @email = 'ins444@gmail.com',@roletype='instructor'
exec [TrainingMangerStpTrg].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 
exec [TrainingMangerStpTrg].stp_DeleteUserAccount @UserId 
--trg
--CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccountON [userAcc].[UserAccount]INSTEAD OF DELETE

------------------------------------------------
----------------student------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].[stp_addstudent] @firstname ,@lastname  ,@gender    ,@birthdate ,@stuaddress,@phone,@nationalid,@userid,@branchid,@intakeid,@trackid   
exec [TrainingMangerStpTrg].[stp_updatestudent] @studentid = 1,@stuaddress = '6th of october, giza', @phone = '01122334455';
exec [TrainingMangerStpTrg].[stp_deletestudent] @studentid = 5;
--trg
--create or alter trigger [useracc].[trg_preventdeletestudent]on [useracc].[student]instead of delete
------------------------------------------------
----------------instructor------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStpTrg].stp_addinstructor 
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
    
exec [TrainingMangerStpTrg].stp_updateinstructor 
    @insid = 1,                 -- —ﬁ„ «·„œ—” ›Ì «·ÃœÊ·
    @salary = 9500.50,          -- «·—« » «·ÃœÌœ (·«“„ > 4000)
    @specialization = 'Data Science'; -- «· Œ’’ «·ÃœÌœ

exec [trainingmangerstptrg].stp_deleteinstructor @instructoid
--trg
--CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor] ON [useracc].[instructor] INSTEAD OF DELETE
---------------------------------------------




