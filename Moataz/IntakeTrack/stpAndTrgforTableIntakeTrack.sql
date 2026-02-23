use [ExaminationSystemDB]


create proc [orgnization].stp_addIntakeTrack
    @intakeid int,
    @trackid int
as
begin
    begin try
        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @intakeid and [isActive] = 1)
        begin
            raiserror('error: intake not found or is inactive.', 16, 1);
            return;
        end

        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @trackid and [isActive] = 1)
        begin
            raiserror('error: track not found or is inactive.', 16, 1);
            return;
        end

       
        insert into [orgnization].[IntakeTrack] ([IntakeId], [TrackId])
        values (@intakeid, @trackid);

        print 'track assigned to intake successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end

create proc [orgnization].stp_ToggleIntakeTrack
    @intakeid int,
    @trackid int,
    @status bit
as
begin
    set nocount on;
    if not exists (select 1 from [orgnization].[IntakeTrack] where [IntakeId] = @intakeid and [TrackId] = @trackid)
    begin
        raiserror('error: this relation does not exist.', 16, 1);
        return;
    end

    update [orgnization].[IntakeTrack]
    set [isActive] = @status
    where [IntakeId] = @intakeid and [TrackId] = @trackid;

    print 'intaketrack status updated.';
end

create proc [orgnization].stp_DeleteIntakeTrack
    @intakeid int,
    @trackid int
as
begin
    begin try
        if not exists (select 1 from [orgnization].[IntakeTrack] 
                       where [IntakeId] = @intakeid and [TrackId] = @trackid)
        begin
            raiserror('error: this relation was not found.', 16, 1);
            return;
        end

        delete from [orgnization].[IntakeTrack] 
        where [IntakeId] = @intakeid and [TrackId] = @trackid;

    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end

create trigger [orgnization].trg_SoftDeleteIntakeTrack
on [orgnization].[IntakeTrack]
instead of delete
as
begin
    declare @intakeid int, @trackid int;
    
    select @intakeid = [IntakeId], @trackid = [TrackId] from deleted;

    if exists (select 1 from [userAcc].[Student] where [IntakeId] = @intakeid and [TrackId] = @trackid)
        or exists (select 1 from [Courses].[CourseInstance] where [IntakeId] = @intakeid and [TrackId] = @trackid)
    begin
        update [orgnization].[IntakeTrack]
        set [isActive] = 0
        where [IntakeId] = @intakeid and [TrackId] = @trackid;
        
        print 'students are enrolled and exist asome courses . status changed to inactive instead of deletion.';
    end
    else 
    begin
        delete from [orgnization].[IntakeTrack] 
        where [IntakeId]= @intakeid and [TrackId] = @trackid;
        
        print 'success: intaketrack relation deleted from database.';
    end
end
