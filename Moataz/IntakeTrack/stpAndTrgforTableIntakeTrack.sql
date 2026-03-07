use [ExaminationSystemDB]

go
create or alter proc [TrainingMangerStp].stp_addIntakeTrack
    @intakeid int,
    @trackid int

as
begin
    set nocount on;
    begin try

        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @intakeid and [isActive] = 1 and [isDeleted] = 0)
            throw 50006, 'Error: Intake not found, inactive, or it has been deleted.', 1;

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @trackid and [isActive] = 1 and [isDeleted] = 0)
            throw 50007, 'Error: Track not found, inactive, or it has been deleted.', 1;

        if exists (select 1 from [orgnization].[IntakeTrack] where [IntakeId] = @intakeid and [TrackId] = @trackid)
            throw 50008, 'Error: This intake-track relation already exists.', 1;    

        insert into [orgnization].[IntakeTrack] ([IntakeId], [TrackId])
        values (@intakeid, @trackid);



    end try
    begin catch
        throw;  
    end catch
end

go

create or alter proc [TrainingMangerStp].stp_ToggleIntakeTrack
    @intakeid int,
    @trackid int,
    @status bit

as
begin
    set nocount on;
    if not exists (select 1 from [orgnization].[IntakeTrack] where [IntakeId] = @intakeid and [TrackId] = @trackid and [isDeleted] = 0 and [isActive] = 1)
        throw 50008, 'Error: This intake-track relation not found, inactive, or it has been deleted.', 1;   

    update [orgnization].[IntakeTrack]
    set [isActive] = @status , [isDeleted] = case when @status = 0 then 1 else 0 end
    where [IntakeId] = @intakeid and [TrackId] = @trackid;

    select @intakeid as IntakeId, @trackid as TrackId, @status as NewStatus;

end
go
create or alter proc [TrainingMangerStp].stp_DeleteIntakeTrack
    @intakeid int,
    @trackid int

as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [orgnization].[IntakeTrack] where [IntakeId] = @intakeid and [TrackId] = @trackid and [isDeleted] = 0)
             throw 50008, 'Error: This intake-track relation not found or it has been deleted.', 1;

        delete from [orgnization].[IntakeTrack] 
        where [IntakeId] = @intakeid and [TrackId] = @trackid;

    end try
    begin catch
throw;
    end catch
end
go
create or alter trigger [orgnization].trg_SoftDeleteIntakeTrack
on [orgnization].[IntakeTrack]
instead of delete
as
begin
    set nocount on;
    declare @intakeid int, @trackid int;
    
    select @intakeid = [IntakeId], @trackid = [TrackId] from deleted;

    if exists (select 1 from [userAcc].[Student] where [IntakeId] = @intakeid and [TrackId] = @trackid)
        or exists (select 1 from [Courses].[CourseInstance] where [IntakeId] = @intakeid and [TrackId] = @trackid)
    begin
        update [orgnization].[IntakeTrack]
        set [isActive] = 0 , [isDeleted] =1
        where [IntakeId] = @intakeid and [TrackId] = @trackid;
        
    end
    else 
    begin
        delete from [orgnization].[IntakeTrack] 
        where [IntakeId]= @intakeid and [TrackId] = @trackid;
        
    end
end