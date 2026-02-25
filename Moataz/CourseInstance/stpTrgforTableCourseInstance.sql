create proc[Courses].stp_addCourseInstance
    @courseid     int,
    @instructorid int,
    @branchid     int,
    @trackid      int,
    @intakeid     int,
    @academicyear int
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Courses].[Course] where [CourseId] = @courseid and [isActive] = 1)
            throw 54001, 'error: course not found or is inactive.', 1;

        if not exists (select 1 from [userAcc].[Instructor]  where [InsId] = @instructorid and [isActive] = 1)
            throw 54002, 'error: instructor not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @branchid and [isActive] = 1)
            throw 54003, 'error: branch not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @trackid and [isActive] = 1)
            throw 54004, 'error: track not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @intakeid and [isActive] = 1)
            throw 54005, 'error: intake not found or is inactive.', 1;

        if exists (select 1 from [Courses].[CourseInstance]
                   where [CourseId] = @courseid and [TrackId] = @trackid 
                   and [IntakeId] = @intakeid and [AcademicYear]  = @academicyear)
            throw 54006, 'error: this course instance already exists for this track and year.', 1;

        insert into  [Courses].[CourseInstance](courseid, instructorid, branchid, trackid, intakeid, academicyear )
        values (@courseid, @instructorid, @branchid, @trackid, @intakeid, @academicyear);

        print 'success: course instance created and assigned successfully.';
    end try
    begin catch
        throw;
    end catch
end;


create proc [Courses].stp_updatecourseinstance
    @instanceid    int,            
    @courseid      int = null,       
    @instructorid  int = null,       
    @branchid      int = null,
    @trackid       int = null,
    @intakeid      int = null,
    @academicyear  int = null
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [courses].[CourseInstance] where [CourseInstanceId] = @instanceid)
            throw 55000, 'error: course instance record not found.', 1;

        declare @curcourse int, @curins int, @curbranch int, @curtrack int, @curintake int, @curyear int;
        
        select 
            @curcourse =[CourseId] , @curins =[InstructorId] , @curbranch = [BranchId], 
            @curtrack =[TrackId] , @curintake =[IntakeId] , @curyear = [AcademicYear]
        from [courses].[CourseInstance] 
        where [CourseInstanceId] = @instanceid;

        set @curcourse = coalesce(@courseid, @curcourse);
        set @curins    = coalesce(@instructorid, @curins);
        set @curbranch = coalesce(@branchid, @curbranch);
        set @curtrack  = coalesce(@trackid, @curtrack);
        set @curintake = coalesce(@intakeid, @curintake);
        set @curyear   = coalesce(@academicyear, @curyear);

        if not exists (select 1 from [courses].[Course] where [CourseId] = @curcourse and [isActive] = 1)
            throw 55001, 'error: target course is inactive or not found.', 1;

        if not exists (select 1 from [useracc].[Instructor] where [InsId] = @curins and [isActive] = 1)
            throw 55002, 'error: target instructor is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @curbranch and [isActive] = 1)
            throw 55003, 'error: target branch is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @curtrack and [isActive] = 1)
            throw 55004, 'error: target track is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @curintake and [isActive] = 1)
            throw 55005, 'error: target intake is inactive or not found.', 1;

        if exists (select 1 from [courses].[CourseInstance] 
                   where  [CourseId]= @curcourse and[TrackId]  = @curtrack 
                   and [IntakeId] = @curintake and [AcademicYear] = @curyear
                   and [CourseInstanceId] <> @instanceid) 
            throw 55006, 'error: another instance already exists with these same details.', 1;

        update [courses].courseinstance
        set 
             [CourseId]    = @curcourse,
             [InstructorId]= @curins,
             [BranchId]    = @curbranch,
             [TrackId]     = @curtrack,
             [IntakeId]    = @curintake,
             [AcademicYear]= @curyear
        where [CourseInstanceId] = @instanceid;

        print 'success: course instance updated successfully.';

    end try
    begin catch
        throw;
    end catch
end;

create  proc [courses].stp_deleteinstance
    @instanceid int
as
begin
    set nocount on;

 
    if not exists (select 1 from [courses].courseinstance where courseinstanceid = @instanceid)
    begin
        throw 56001, 'error: course instance not found.', 1;
    end
    begin try
        delete from [courses].courseinstance 
        where courseinstanceid = @instanceid;
        
        print 'delete command executed. check messages for final result.';
    end try
    begin catch
        throw; 
    end catch
end


create  trigger [courses].trg_preventdeleteinstance
on [courses].[courseinstance]
instead of delete
as
begin
    set nocount on;

    declare @instanceid int, @courseid int, @year int;
    select @instanceid = courseinstanceid, @courseid = courseid, @year = academicyear from deleted;

    if exists (select 1 from[exams].[Exam]  where [CourseInstanceId] = @instanceid)
    begin
        raiserror ('cannot delete or deactivate: this course instance has recorded exams .', 16, 1);
        rollback transaction;
    end
    else
    begin

        delete from [courses].[CourseInstance]
        where [CourseInstanceId] = @instanceid;

        print 'success: course instance id (' + cast(@instanceid as nvarchar) + ') deleted permanently.';
    end
end;
