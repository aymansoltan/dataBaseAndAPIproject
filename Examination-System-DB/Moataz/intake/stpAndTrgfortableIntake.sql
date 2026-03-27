use [ExaminationSystemDB]
go
create or alter proc [TrainingMangerStp].stp_AddIntake
    @IntakeName varchar(10)
as
begin
    set nocount on;
    begin try
        if len(trim(@IntakeName)) < 2
            throw 50001, 'Error: Intake name must be at least 2 characters long.', 1;
     
        if exists (select 1 from [Intake] where [IntakeName] = @IntakeName)
            throw 50002, 'Error: This intake name already exists.', 1;
        declare @LastIntakeDate date;
        
        select top 1 @LastIntakeDate = createdAt 
        from [Intake] 
        where isDeleted = 0 
        order by IntakeId desc; 
        if @LastIntakeDate is not null
        begin
            if datediff(month, @LastIntakeDate, getdate()) < 3
                throw 50009, 'Error: Cannot create a new intake. At least 3 months must pass since the last intake was created.', 1;
        end

        insert into [Intake] ([IntakeName])
        values (trim(@IntakeName));

    end try
    begin catch
        throw;  
    end catch
end
go

create or alter proc [TrainingMangerStp].stp_UpdateIntake
    @IntakeId tinyint,
    @IntakeName varchar(10)
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Intake] where [IntakeId] = @IntakeId and [isDeleted] = 0 )
            throw 50003, 'Error: Intake not found or it has been deleted.', 1;

        if len(trim(@IntakeName)) <3
            throw 50001, 'Error: Intake name must be at least 2 characters long.', 1;

         if exists (select 1 from [Intake] where [IntakeName] = @IntakeName and [IntakeId] <> @IntakeId)
            throw 50002, 'Error: This intake name already exists.', 1;

        update [Intake]
        set [IntakeName] = trim(@IntakeName)
        where [IntakeId] = @IntakeId;

    end try
    begin catch
        throw;  
    end catch
end

go

create or alter proc [TrainingMangerStp].stp_DeleteIntake @IntakeId tinyint 
as
begin
    set nocount on;
    begin try
        if not exists(select 1 from [Intake] where [IntakeId] = @IntakeId and [isDeleted] = 0 )
            throw 50003, 'Error: Intake not found or it has been deleted.', 1;

        delete from [Intake] where [IntakeId] = @IntakeId
    end try
    begin catch
        throw;  
    end catch
end
go

create or alter trigger [orgnization].trg_SoftDeleteIntake
on [orgnization].[Intake]
instead of delete
as
begin
    set nocount on;
    declare @Intakeid tinyint;
    select @Intakeid = [IntakeId] from deleted;

    if exists (select 1 from [Students] where [IntakeId] = @Intakeid)
        or exists(select 1 from [IntakeTrack] where [IntakeId] = @Intakeid )
        or exists(select 1 from [CourseInstance] where [IntakeId] = @Intakeid )

    begin
        update [Intake]
        set [isActive] = 0 , [isDeleted] = 1
        where [IntakeId] = @Intakeid;
        
    end
    else 
    begin
        delete from [Intake] where [IntakeId] = @Intakeid;
    end
end
go

create or alter trigger [orgnization].trg_syncIntakeTrackStatus
on [orgnization].[Intake]
after update
as
begin
    set nocount on;
    
    update IT
    set IT.isActive = i.isActive,
        IT.isDeleted = i.isDeleted
    from [orgnization].[IntakeTrack] IT
    inner join inserted i on IT.IntakeId = i.IntakeId
    inner join deleted d on i.IntakeId = d.IntakeId
    where i.isActive <> d.isActive or i.isDeleted <> d.isDeleted;
end
go
