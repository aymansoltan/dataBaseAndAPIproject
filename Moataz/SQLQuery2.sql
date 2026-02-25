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
