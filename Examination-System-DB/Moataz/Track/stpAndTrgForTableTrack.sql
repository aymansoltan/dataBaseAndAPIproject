use [ExaminationSystemDB]
go
create or alter proc  [TrainingMangerStp].stp_AddTrack
    @TrackName varchar(40),
    @DeptId tinyint
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Department] where [DeptId] = @DeptId and [isActive] = 1 and [isDeleted] = 0)
            throw 50004, 'Error: Department not found, inactive, or it has been deleted.', 1;

        if len(trim(@TrackName)) < 3
            throw 50005, 'Error: Track name must be at least 3 characters long.', 1;

        if exists (select 1 from [Track] where [TrackName] = @TrackName and [DeprtmentId] = @DeptId)
            throw 50006, 'Error: A track with this name already exists in the specified department.', 1;
        declare @NewTrackId smallint;
        declare @LatestIntakeId tinyint;

        select top 1 @LatestIntakeId = IntakeId 
        from [Intake] 
        where isDeleted = 0 and isActive = 1
        order by IntakeId desc;

        if @LatestIntakeId is null
            throw 50008, 'Error: No active intake found to link with the track.', 1;

        insert into [Track] ([TrackName], [DeprtmentId])
        values (trim(@TrackName), @DeptId);
        set @NewTrackId = SCOPE_IDENTITY();
        insert into [IntakeTrack] (IntakeId, TrackId)
        values (@LatestIntakeId, @NewTrackId);

    end try
    begin catch
        throw;  
    end catch
end
go

create or alter proc [TrainingMangerStp].stp_UpdateTrack
    @TrackId smallint,
    @TrackName varchar(40),
    @DeptId tinyint
as
begin
    set nocount on;
    begin try
     
        if not exists (select 1 from [Track] where [TrackId] = @TrackId and [isDeleted] = 0 and [isActive] = 1)
            throw 50007, 'Error: Track not found, inactive, or it has been deleted.', 1;

   
        if not exists (select 1 from [Department] where [DeptId] = @DeptId and [isActive] = 1 and [isDeleted] = 0 )
            throw 50004, 'Error: Department not found, inactive, or it has been deleted.', 1;

        if exists (select 1 from [Track] where [TrackName] = @TrackName and [DeprtmentId] = @DeptId and [TrackId] <> @TrackId)
            throw 50006, 'Error: A track with this name already exists in the specified department.', 1;

        update [Track]
        set [TrackName] = trim(@TrackName),
            [DeprtmentId] = @DeptId
        where [TrackId] = @TrackId;

        declare @LatestIntakeId tinyint;
        select top 1 @LatestIntakeId = IntakeId from [Intake] where isDeleted = 0 and isActive = 1 order by IntakeId desc;

        if @LatestIntakeId is not null
        begin
            if not exists (select 1 from [IntakeTrack] where [TrackId] = @TrackId and [IntakeId] = @LatestIntakeId)
            begin
                insert into [IntakeTrack] (IntakeId, TrackId)
                values (@LatestIntakeId, @TrackId);
            end
        end
    end try
    begin catch
        throw;
    end catch
end
go


create or alter proc  [TrainingMangerStp].stp_DeleteTrack
    @trackid smallint
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Track] where [TrackId] = @trackid and [isDeleted] = 0 and [isActive] = 1)
            throw 50007, 'Error: Track not found, inactive, or it has been deleted.', 1;
        delete from [Track] where [TrackId] = @trackid;
    end try
    begin catch
        throw;
    end catch
end
go



create or alter trigger [orgnization].trg_SoftDeleteTrack
on [orgnization].[Track]
instead of delete
as
begin
    set nocount on;
    declare @Trackid smallint;
    select @Trackid = [TrackId] from deleted;

    if exists (select 1 from [Students] where [TrackId] = @Trackid)
       or exists (select 1 from [CourseInstance] where [TrackId] = @Trackid)
    begin
        update [Track]
        set [isActive] = 0 , [isDeleted] = 1
        where [TrackId] = @Trackid;
    end
    else 
    begin
        delete from [Track] where [TrackId] = @Trackid;
    end
end

go

create or alter trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveTrack
on [orgnization].[Track]
after update
as
begin
    set nocount on;
    if exists (select 1 from inserted i join deleted d on i.TrackId = d.TrackId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @trackid smallint;
        select @trackid = TrackId from inserted;

   
        update [IntakeTrack]
        set [isActive] = 0
        where [TrackId] = @trackid;

    end
end
