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

exec [TrainingMangerStp].stp_AddDepartment @Deptname ='Full Stack .net', @BranchId =1
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
exec [TrainingMangerStp].stp_UpdateIntake @IntakeId =5 ,@IntakeName ='sssssssss' 
exec [TrainingMangerStp].stp_DeleteIntack @IntakeId =5
--trg
--create trigger [orgnization].trg_SoftDeleteIntakeon [orgnization].[Intake]instead of delete
--create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntakeon [orgnization].[Intake]after update
------------------------------------------------
----------------IntakeTrack----------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].stp_addIntakeTrack @intakeid =1 ,@trackid=2
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
exec [TrainingMangerStp].[stp_createsystemuser] 'Hassan', 'Inst@123', 'Hassan@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'Mariam', 'Inst@123', 'Mariam@exam.com', 'instructor';
exec [TrainingMangerStp].[stp_createsystemuser] 'Moatz', 'Std@123', 'Moatz@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Fady', 'Std@123', 'Fady@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Omar', 'Stu@123', 'Omar@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Marco', 'Stu@123', 'Marco@exam.com', 'student';
exec [TrainingMangerStp].[stp_createsystemuser] 'Ragab', 'Stu@123', 'Ragab@exam.com', 'student';



exec [TrainingMangerStp].[sp_updateuseraccount] @userid ,@username ,@email ,@userpassword ,@isactive ,@roleid 
exec [TrainingMangerStp].stp_DeleteUserAccount @UserId 
--trg
--CREATE OR ALTER TRIGGER [userAcc].trg_SoftDeleteUserAccountON [userAcc].[UserAccount]INSTEAD OF DELETE

------------------------------------------------
----------------student------------------------
------------------------------------------------
--Stp
exec [TrainingMangerStp].[stp_addstudent] 'Moatz' ,'Ahmed'  ,'M'   ,'1985-05-20' ,'Minya','30108222501474',5,1,1,1   
select * from [userAcc].[UserAccount]
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Moatz' ,@lastname='Ahmed'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650211',@nationalid='30108222501474',@userid=5,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Fady' ,@lastname='Sameh'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650214',@nationalid='30108222501476',@userid=6,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Omar' ,@lastname='Kotb'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650213',@nationalid='30108222501477',@userid=7,@branchid=1,@intakeid=1,@trackid=1 
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Marco' ,@lastname='Samh'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650215',@nationalid='30108222501475',@userid=8,@branchid=1,@intakeid=1,@trackid=2
exec [TrainingMangerStp].[stp_addstudent] @firstname ='Ragab' ,@lastname='Ahmed'  ,@gender='M'    ,@birthdate='1985-05-20' ,@stuaddress='6th of october, giza',@phone='01146650218',@nationalid='30108222501478',@userid=9,@branchid=1,@intakeid=1,@trackid=2 

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
    


exec [TrainingMangerStp].stp_updateinstructor 
    @insid = 1,                 -- —ﬁ„ «·„œ—” ›Ì «·ÃœÊ·
    @salary = 9500.50,          -- «·—« » «·ÃœÌœ (·«“„ > 4000)
    @specialization = 'Data Science'; -- «· Œ’’ «·ÃœÌœ

exec [trainingmangerstp].stp_deleteinstructor @instructoid


--trg
--CREATE OR ALTER TRIGGER [useracc].[trg_preventdeleteinstructor] ON [useracc].[instructor] INSTEAD OF DELETE
-- Courses--------------
EXEC [TrainingMangerStp].stp_AddCourse 'Web Fundamentals (HTML/CSS)', 100, 50, 'Building responsive web pages';
EXEC [TrainingMangerStp].stp_AddCourse 'JavaScript & ES6', 100, 50, 'Modern JavaScript for Web Development';
EXEC [TrainingMangerStp].stp_AddCourse 'Introduction to Linux', 100, 50, 'Linux Administration and Shell Scripting';
EXEC [TrainingMangerStp].stp_AddCourse 'Cloud Computing (Azure)', 100, 60, 'Deploying and managing cloud resources';

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

    select * from [Courses].[Course]
        select * from [userAcc].[Instructor]
            select * from [orgnization].[Track]
--Question------------------------------------------------------
('mcq', 't/f', 'text')
EXEC [InstructorStp].stp_createquestion
    @questiontext='html html html html ',
    @questiontype='t/f'  ,        
    @correctanswer='True' ,
    @bestanswer='True'    ,
    @points =2      ,
    @courseid=1     


    EXEC [InstructorStp].stp_createquestion
    @questiontext='css html html html ',
    @questiontype='mcq'  ,        
    @correctanswer='A' ,
    @bestanswer='A'    ,
    @points =4      ,
    @courseid=1,
    @optionlist = 'A-omar |B-Moatz |C-Fady'

        EXEC [InstructorStp].stp_createquestion
    @questiontext='JS html html html ',
    @questiontype='text'  ,        
    @bestanswer=' js js js'    ,
    @points =4      ,
    @courseid=1

---------------------------------------------
--------------VIEWS--------------------------
---------------------------------------------
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



