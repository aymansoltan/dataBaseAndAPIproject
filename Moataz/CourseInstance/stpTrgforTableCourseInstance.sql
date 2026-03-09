use  [ExaminationSystemDB]
go
create or alter proc[TrainingMangerStp].stp_addCourseInstance
    @courseid     smallint,
    @instructorid int,
    @branchid     tinyint,
    @trackid      smallint,
    @intakeid     tinyint,
    @academicyear smallint
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Courses].[Course] where [CourseId] = @courseid and [isActive] = 1 and [isDeleted] = 0)
            throw 54001, 'error: course not found or is inactive.', 1;

        if not exists (select 1 from [userAcc].[Instructor]  where [InstructorId] = @instructorid and [isActive] = 1 and [isDeleted] = 0)
            throw 54002, 'error: instructor not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @branchid and [isActive] = 1 and [isDeleted] = 0)
            throw 54003, 'error: branch not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @trackid and [isActive] = 1 and [isDeleted] = 0)
            throw 54004, 'error: track not found or is inactive.', 1;

        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @intakeid and [isActive] = 1 and [isDeleted] = 0)
            throw 54005, 'error: intake not found or is inactive.', 1;

        if exists (select 1 from [Courses].[CourseInstance]
                   where [CourseId] = @courseid and [InstructorId] = @instructorid and [TrackId] = @trackid 
                   and [IntakeId] = @intakeid and [AcademicYear]  = @academicyear)
            throw 54006, 'error: this course instance already exists for this track and year.', 1;

        insert into  [Courses].[CourseInstance](courseid, instructorid, branchid, trackid, intakeid, academicyear )
        values (@courseid, @instructorid, @branchid, @trackid, @intakeid, @academicyear);

       select scope_identity() as NewCourseInstanceId, 1 as Success, 'Course instance added successfully.' as Message;
    end try
    begin catch
        throw;
    end catch
end;
go

create or alter proc [TrainingMangerStp].stp_updatecourseinstance
    @instanceid    smallint,            
    @courseid      smallint = null,       
    @instructorid  int = null,       
    @branchid      tinyint = null,
    @trackid       smallint = null,
    @intakeid      tinyint = null,
    @academicyear  smallint = null
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [courses].[CourseInstance] where [CourseInstanceId] = @instanceid and [isDeleted] = 0)
            throw 55000, 'error: course instance not found or has been deleted.', 1;

        declare @CId smallint, @InsId int, @BrId tinyint, @TrId smallint, @IntakeId tinyint, @AcademicYear smallint;
        
        select 
            @CId =[CourseId] , @InsId =[InstructorId] , @BrId = [BranchId], 
            @TrId =[TrackId] , @IntakeId =[IntakeId] , @AcademicYear = [AcademicYear]
        from [courses].[CourseInstance] 
        where [CourseInstanceId] = @instanceid;

        set @CId = coalesce(@courseid, @CId);
        set @InsId    = coalesce(@instructorid, @InsId);
        set @BrId = coalesce(@branchid, @BrId);
        set @TrId  = coalesce(@trackid, @TrId);
        set @IntakeId = coalesce(@intakeid, @IntakeId);
        set @AcademicYear   = coalesce(@academicyear, @AcademicYear);

         
        if not exists (select 1 from [courses].[Course] where [CourseId] = @CId and [isActive] = 1 and [isDeleted] = 0)
            throw 55001, 'error: target course is inactive or not found.', 1;

        if not exists (select 1 from [useracc].[Instructor] where [InstructorId] = @InsId and [isActive] = 1 and [isDeleted] = 0)
            throw 55002, 'error: target instructor is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @BrId and [isActive] = 1 and [isDeleted] = 0)
            throw 55003, 'error: target branch is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @TrId and [isActive] = 1 and [isDeleted] = 0)
            throw 55004, 'error: target track is inactive or not found.', 1;

        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @IntakeId and [isActive] = 1 and [isDeleted] = 0)
            throw 55005, 'error: target intake is inactive or not found.', 1;

        if exists (select 1 from [courses].[CourseInstance] 
                where  [CourseId]= @CId and[TrackId]  = @TrId 
                and [IntakeId] = @IntakeId and [AcademicYear] = @AcademicYear
                and [CourseInstanceId] <> @instanceid) 
            throw 55006, 'error: another instance already exists with these same details.', 1;

        update [courses].courseinstance
        set 
            [CourseId]    = @CId,
            [InstructorId]= @InsId,
            [BranchId]    = @BrId,
            [TrackId]     = @TrId,
            [IntakeId]    = @IntakeId,
            [AcademicYear]= @AcademicYear
        where [CourseInstanceId] = @instanceid;

        select @instanceid as UpdatedCourseInstanceId, 1 as Success, 'Course instance updated successfully.' as Message;

    end try
    begin catch
        throw;
    end catch
end;
go
create or alter proc [TrainingMangerStp].stp_deleteinstance
    @instanceid smallint
as
begin
    set nocount on;

    if not exists (select 1 from [courses].courseinstance where courseinstanceid = @instanceid and [isDeleted] = 0)
        throw 55010, 'error: course instance not found or has been deleted.', 1;
    begin try
        delete from [courses].courseinstance 
        where courseinstanceid = @instanceid;
        
        select 1 as Success, 'Course instance deleted successfully.' as Message;
        
    end try
    begin catch
        throw; 
    end catch
end
go

create or alter  trigger [courses].trg_preventdeleteinstance
on [courses].[courseinstance]
instead of delete
as
begin
    set nocount on;

    declare @instanceid smallint, @courseid smallint, @year smallint;
    select @instanceid = courseinstanceid, @courseid = courseid, @year = academicyear from deleted;

    if exists (select 1 from[exams].[Exam]  where [CourseInstanceId] = @instanceid and [isDeleted] = 0) 
    or exists (select 1 from [exams].[Question] where [CourseInstanceId] = @instanceid and [isDeleted] = 0)
    or exists (select 1 from [results].[Result] where [CourseInstanceId] = @instanceid and [isDeleted] = 0)
    or exists (select 1 from [students].[StudentCourseInstance] where [CourseInstanceId] = @instanceid and [isDeleted] = 0)
    begin
        update [courses].[courseinstance]
        set [isActive] = 0, [isDeleted] = 1
        where courseinstanceid = @instanceid;
    end
    else
    begin
        delete from [courses].[CourseInstance]
        where [CourseInstanceId] = @instanceid;
    end
    
end;
