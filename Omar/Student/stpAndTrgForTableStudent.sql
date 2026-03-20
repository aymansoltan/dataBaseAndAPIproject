USE [ExaminationSystemDB]
GO

/* =========================================================
   Student Module (Production-Ready Enterprise Version)
   ========================================================= */

------------------------------------------------------------
-- 1) Add Student
------------------------------------------------------------
go
create  procedure [TrainingMangerStp].[stp_addstudent]
    @firstname nvarchar(50),
    @lastname  nvarchar(50),
    @gender    char(1),
    @birthdate date,
    @stuaddress nvarchar(150),
    @phone     nvarchar(11),
    @nationalid nchar(14),
    @userid    int,
    @branchid  int,
    @intakeid  int,
    @trackid   int
as
begin
    set nocount on;
    begin try
      
        if len(ltrim(rtrim(@firstname))) < 3 or len(ltrim(rtrim(@lastname))) < 3
            throw 51000, 'error: first and last name must be at least 3 characters.', 1;

      
        if exists (select 1 from [userAcc].[Student] where [Phone]  = @phone)
            throw 51008, 'error: phone number already exists.', 1;

        if exists (select 1 from [userAcc].[Student] where [NationalID] = @nationalid)
            throw 51009, 'error: national id already exists.', 1;

        if not exists (
            select 1
            from [userAcc].[UserAccount]  ua
            join [userAcc].[UserRole] r on ua.RoleId = r.RoleId
            where ua.UserId = @userid
              and ua.isActive = 1
              and r.RoleName = 'student'
        )
            throw 51001, 'error: invalid or inactive student user.', 1;

        if exists (select 1 from[userAcc].[Student]  where [UserId] = @userid)
            throw 51002, 'error: this user is already linked to a student profile.', 1;

        if exists (select 1 from [userAcc].Instructor where UserId = @userid)
            throw 51003, 'error: a user cannot be both a student and an instructor.', 1;

        if not exists (select 1 from [orgnization].[Branch] where BranchId = @branchid and isActive = 1)
            throw 51004, 'error: invalid or inactive branch.', 1;

        if not exists (select 1 from [orgnization].[Intake] where IntakeId = @intakeid and isActive = 1)
            throw 51005, 'error: invalid or inactive intake.', 1;

        if not exists (select 1 from [orgnization].Track where TrackId = @trackid and  isActive= 1)
            throw 51006, 'error: invalid or inactive track.', 1;

        if not exists (
            select 1 from [orgnization].IntakeTrack
            where IntakeId = @intakeid and TrackId = @trackid and isActive = 1
        )
            throw 51007, 'error: the selected track does not belong to this intake.', 1;

      
        insert into [userAcc].Student(
            firstname, lastname, gender, birthdate,
            stuaddress, phone, nationalid,
            userid, branchid, intakeid, trackid
        )
        values (
            lower(trim(@firstname)), 
            lower(trim(@lastname)), 
            upper(@gender),
            @birthdate,
            @stuaddress,
            @phone,
            @nationalid,
            @userid,
            @branchid,
            @intakeid,
            @trackid
        );

        print 'student profile created and linked successfully.';
    end try
    begin catch
        throw;
    end catch
end;
go


------------------------------------------------------------
-- 2) Update Student
------------------------------------------------------------
go
create  procedure [TrainingMangerStp].[stp_updatestudent]
    @studentid int,
    @firstname nvarchar(50) = null,
    @lastname  nvarchar(50) = null,
    @gender    char(1)      = null,
    @birthdate date         = null,
    @stuaddress nvarchar(150) = null,
    @phone     nvarchar(11) = null,
    @nationalid nchar(14)   = null,
    @branchid  int          = null,
    @intakeid  int          = null,
    @trackid   int          = null,
    @isactive  bit          = null
as
begin
    set nocount on;
    begin try
        begin transaction;

        -- 1. «· √ﬂœ „‰ ÊÃÊœ «·ÿ«·»
        if not exists (select 1 from [useracc].student where studentid = @studentid)
            throw 51020, 'error: student not found.', 1;

        -- 2. «· Õﬁﬁ „‰ ›—«œ… «· ·Ì›Ê‰ (»«” À‰«¡ «·ÿ«·» ‰›”Â)
        if @phone is not null and exists (
            select 1 from [useracc].student 
            where phone = @phone and studentid <> @studentid
        )
            throw 51022, 'error: phone number already exists for another student.', 1;

        -- 3. «· Õﬁﬁ „‰ ›—«œ… «·—ﬁ„ «·ﬁÊ„Ì
        if @nationalid is not null and exists (
            select 1 from [useracc].student 
            where nationalid = @nationalid and studentid <> @studentid
        )
            throw 51023, 'error: national id already exists for another student.', 1;

        -- 4. «· Õﬁﬁ „‰ «·›—⁄ (·Ê „»⁄Ê )
        if @branchid is not null and not exists (
            select 1 from [orgnization].branch where branchid = @branchid and isactive = 1
        )
            throw 51024, 'error: invalid or inactive branch.', 1;

        -- 5. „‰ÿﬁ «·‹ Intake Ê«·‹ Track
        declare @currentintake int, @currenttrack int;
        select @currentintake = intakeid, @currenttrack = trackid 
        from [useracc].student where studentid = @studentid;

        declare @finalintake int = coalesce(@intakeid, @currentintake);
        declare @finaltrack  int = coalesce(@trackid, @currenttrack);

        -- «· √ﬂœ „‰ ’Õ… «·—»ÿ »Ì‰ «·‹ Intake Ê«·‹ Track «·ÃœÌœ/«·Õ«·Ì
        if not exists (
            select 1 from [orgnization].intaketrack 
            where intakeid = @finalintake and trackid = @finaltrack and isactive = 1
        )
            throw 51021, 'error: invalid intake/track combination.', 1;

        -- 6. «· ÕœÌÀ «·›⁄·Ì
        update [useracc].student
        set 
            firstname  = coalesce(lower(trim(@firstname)), firstname),
            lastname   = coalesce(lower(trim(@lastname)), lastname),
            gender     = coalesce(upper(@gender), gender),
            birthdate  = coalesce(@birthdate, birthdate),
            stuaddress = coalesce(@stuaddress, stuaddress),
            phone      = coalesce(@phone, phone),
            nationalid = coalesce(@nationalid, nationalid),
            branchid   = coalesce(@branchid, branchid),
            intakeid   = @finalintake,
            trackid    = @finaltrack,
            isactive   = coalesce(@isactive, isactive)
        where studentid = @studentid;

        commit transaction;
        print 'student updated successfully.';

    end try
    begin catch
        if @@trancount > 0 rollback transaction;
        throw;
    end catch
end;
go


------------------------------------------------------------
-- 3) Delete Student (Soft Delete Only)
------------------------------------------------------------
go
create proc [TrainingMangerStp].stp_DeleteStudent @StudentId int
as 
begin 
    set nocount on;
    delete from [userAcc].[Student]
    where [StudentId] =@StudentId and [isActive] =1
    
end 



------------------------------------------------------------
-- 4) Soft Delete Trigger
------------------------------------------------------------
go
create  trigger [useracc].[trg_preventdeletestudent]
on [useracc].[student]
instead of delete
as
begin
    set nocount on;

    if exists (
        select 1
        from deleted d
        join [exams].[student_answer] sa on d.studentid = sa.studentid
    )
    begin
        throw 51030, 'error: cannot delete student with submitted answers. use deactivation instead.', 1;
    end

    if exists (
        select 1
        from deleted d
        join [exams].[student_exam_result] sr on d.studentid = sr.studentid
    )
    begin
        throw 51031, 'error: cannot delete student with exam results.', 1;
    end

    update s
    set isactive = 0
    from [useracc].student s
    join deleted d on s.studentid = d.studentid;

    update ua
    set isactive = 0
    from [useracc].useraccount ua
    join [useracc].student s on ua.userid = s.userid
    join deleted d on s.studentid = d.studentid;

    print 'soft delete performed: student and user account deactivated.';
end;
go