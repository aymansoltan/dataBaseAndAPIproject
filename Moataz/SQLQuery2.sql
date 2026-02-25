exec [orgnization].stp_AddBranch @BranchName = 'cairo'
exec [orgnization].stp_UpdateBranch @BranchId = 12 ,@BranchName =Alex , @IsActive  = 1
exec [orgnization].stp_DeleteBranch @BranchId =12
exec [orgnization].stp_ActivateBranch @BranchId =7
-------------------------
exec [orgnization].stp_AddDepartment @Deptname ='Cyber Security', @BranchId =10
exec [orgnization].stp_UpdateDepartment @DeptId =3 , @DeptName='cloud' ,@BranchId =8
exec [orgnization].stp_DeleteDepartment @DeptId =2
---------------------------
exec [orgnization].stp_AddTrack @TrackName='Ethical Hacking' ,@DeptId =5
exec [orgnization].stp_UpdateTrack @TrackId =1 ,@TrackName ='Full Stack .NET' ,@DeptId =1
exec [orgnization].stp_DeleteTrack @trackid =5
-------------------------------------
exec [orgnization].stp_AddIntake @IntakeName='Intake 46'
exec [orgnization].stp_UpdateIntake @IntakeId =5 ,@IntakeName ='sssssssss' 
exec [orgnization].stp_DeleteIntack @IntakeId =5
-----------------
exec [orgnization].stp_addIntakeTrack @intakeid =1 ,@trackid=6
exec [orgnization].stp_ToggleIntakeTrack @intakeid  ,@trackid ,@status
exec [orgnization].stp_DeleteIntakeTrack @intakeid ,@trackid
-------------------------------------------
exec [useracc].[sp_createsystemuser] @username ='admin' ,@password = 'admin@123' , @email = 'admin123@gmail.com',@roletype='admin'
exec [useracc].[sp_createsystemuser] @username ='manager' ,@password = 'man@123' , @email = 'man123@gmail.com',@roletype='manager'
exec [useracc].[sp_createsystemuser] @username ='student1' ,@password = 'stu@123' , @email = 'stu123@gmail.com',@roletype='student'
exec [useracc].[sp_createsystemuser] @username ='student2' ,@password = 'stu@123' , @email = 'stu222@gmail.com',@roletype='student'
exec [useracc].[sp_createsystemuser] @username ='student3' ,@password = 'stu@123' , @email = 'stu333@gmail.com',@roletype='student'
exec [useracc].[sp_createsystemuser] @username ='instructor1' ,@password = 'ins@123' , @email = 'ins123@gmail.com',@roletype='instructor'
exec [useracc].[sp_createsystemuser] @username ='instructor2' ,@password = 'ins@123' , @email = 'ins222@gmail.com',@roletype='instructor'
exec [useracc].[sp_createsystemuser] @username ='instructor3' ,@password = 'ins@123' , @email = 'ins333@gmail.com',@roletype='instructor'
exec [useracc].[sp_createsystemuser] @username ='instructor4' ,@password = 'ins@123' , @email = 'ins444@gmail.com',@roletype='instructor'
exec [useracc].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 

------------------------------------------------
exec [useracc].[stp_addstudent] @firstname ,@lastname  ,@gender    ,@birthdate ,@stuaddress,@phone,@nationalid,@userid,@branchid,@intakeid,@trackid   
exec [useracc].[stp_updatestudent] @studentid = 1,@stuaddress = '6th of october, giza', @phone = '01122334455';
exec [useracc].[stp_deletestudent] @studentid = 5;
-------------------------------
exec [useracc].stp_addinstructor 
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
    
exec [useracc].stp_updateinstructor 
    @insid = 1,                 -- —ﬁ„ «·„œ—” ›Ì «·ÃœÊ·
    @salary = 9500.50,          -- «·—« » «·ÃœÌœ (·«“„ > 4000)
    @specialization = 'Data Science'; -- «· Œ’’ «·ÃœÌœ
---------------------------------------------


-----------------------------------
-- trasfer all stp to trainnig schema
-------------------------------------

ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_AddBranch;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_UpdateBranch;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_DeleteBranch;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_ActivateBranch;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_AddDepartment;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_UpdateDepartment;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_DeleteDepartment;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_AddTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_UpdateTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_DeleteTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_AddIntake;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_UpdateIntake;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_DeleteIntack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_addIntakeTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_ToggleIntakeTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [orgnization].stp_DeleteIntakeTrack;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].[sp_createsystemuser];
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].[sp_updateuseraccount];
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].[stp_addstudent];
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].[stp_updatestudent];
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].[stp_deletestudent];
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].stp_addinstructor;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [useracc].stp_updateinstructor;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [userAcc].stp_DeleteStudent
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [Courses].stp_DeleteCourse;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [Courses].stp_UpdateCourse;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [Courses].stp_AddCourse ;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [Courses].stp_addCourseInstance;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [Courses].stp_updatecourseinstance;
ALTER SCHEMA [TrainingMangerStpTrg] TRANSFER [courses].stp_deleteinstance ;

