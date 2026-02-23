use [ExaminationSystemDB]

create proc [orgnization].stp_AddTrack
    @TrackName nvarchar(50),
    @DeptId int
as
begin
    begin try
        if len(trim(@TrackName)) < 3
        begin
            raiserror('Track name is too short. must be at least 3 characters.', 16, 1);
            return;
        end

        if not exists (select 1 from [orgnization].[Department] where [DeptId] = @DeptId and [isActive] = 1)
        begin
            raiserror('cannot Add track: Department not found or is currently inactive.', 16, 1);
            return;
        end

        if exists (select 1 from [orgnization].[Track] where [TrackName] = @TrackName and [DeprtmentId] = @DeptId)
        begin
            raiserror('this track name already exists in this department.', 16, 1);
            return;
        end

   
        insert into [orgnization].[Track] ([TrackName], [DeprtmentId])
        values (trim(@TrackName), @DeptId);

        print 'track added successfully.';

    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end

create proc [orgnization].stp_UpdateTrack
    @TrackId int,
    @TrackName nvarchar(50),
    @DeptId int
as
begin
    begin try
        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @TrackId)
        begin
            raiserror('error: track id not found.', 16, 1);
            return;
        end

        if not exists (select 1 from [orgnization].[Department] where [DeptId] = @DeptId and [isActive] = 1)
        begin
            raiserror('cannot update: target department is invalid or inactive.', 16, 1);
            return;
        end

        if exists (select 1 from [orgnization].[Track] 
                   where [TrackName] = @TrackName and [DeprtmentId] = @DeptId and [TrackId] <> @TrackId)
        begin
            raiserror('this track name already exists in this department.', 16, 1);
            return;
        end

        update [orgnization].[Track]
        set [TrackName] = trim(@TrackName),
          [DeprtmentId] = @DeptId
        where [TrackId] = @TrackId;

        print 'track updated successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end



create proc [orgnization].stp_DeleteTrack
    @trackid int
as
begin
    begin try
        if not exists (select 1 from [orgnization].[Track] where [TrackId] = @trackid)
        begin
            raiserror('error: track id not found.', 16, 1);
            return;
        end

        delete from [orgnization].[Track] where [TrackId] = @trackid;
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);   
    end catch
end


create trigger [orgnization].trg_SoftDeleteTrack
on [orgnization].[Track]
instead of delete
as
begin
    declare @id int;
    select @id = [TrackId] from deleted;

    if exists (select 1 from [userAcc].[Student] where [TrackId] = @id)
       or exists (select 1 from [Courses].[CourseInstance] where [TrackId] = @id)
    begin
        update [orgnization].[Track]
        set [isActive] = 0
        where [TrackId] = @id;
        
        print 'caution: track is linked to students or courses. changed to inactive.';
    end
    else 
    begin
        delete from [orgnization].[Track] where [TrackId] = @id;
        print 'success: track deleted from database.';
    end
end

create trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveTrack
on [orgnization].[Track]
after update
as
begin

    if exists (select 1 from inserted i join deleted d on i.TrackId = d.TrackId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @trackid int;
        select @trackid = TrackId from inserted;

   
        update [orgnization].[IntakeTrack]
        set [isActive] = 0
        where [TrackId] = @trackid;

        print 'track deactivated: all related intaketracks are now inactive.';
    end
end
