use [ExaminationSystemDB]
go
create or alter proc [TrainingMangerStp].stp_AddIntake
    @IntakeName varchar(10)
as
begin
    set nocount on;
    begin try
        if len(trim(@IntakeName))<2
            throw 50001, 'Error: Intake name must be at least 2 characters long.', 1;
     
        if exists (select 1 from [Intake] where [IntakeName] = @IntakeName)
            throw 50002, 'Error: This intake name already exists.', 1;

        insert into [Intake] ([IntakeName])
        values (trim(@IntakeName));

        select SCOPE_IDENTITY() as NewIntakeId , 1 as Success , 'intake added Successfully' as Message ;
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

        select @IntakeId as UpdatedIntakeId , 1 as Success , 'intake updated Successfully' as Message ;
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
        select 1 as Success , 'intake deleted Successfully' as Message ;
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

create or alter trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntake
on [orgnization].[Intake]
after update
as
begin
    set nocount on;
    if exists (select 1 from inserted i join deleted d on i.IntakeId = d.IntakeId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @intakeid tinyint;
        select @intakeid = IntakeId from inserted;

  
        update [IntakeTrack]
        set [isActive] = 0 , [isDeleted] = 1
        where [IntakeId] = @intakeid;
    end
end