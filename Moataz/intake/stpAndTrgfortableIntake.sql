use [ExaminationSystemDB]
go
create or alter proc [TrainingMangerStp].stp_AddIntake
    @IntakeName nvarchar(50)
as
begin
    begin try
        if len(trim(@IntakeName))<2
        begin
            raiserror('error: this intake name  must be at least 2 letters.', 16, 1);
            return;
        end
     
        if exists (select 1 from [orgnization].[Intake] where [IntakeName] = @IntakeName)
        begin
            raiserror('error: this intake name already exists.', 16, 1);
            return;
        end

        insert into [orgnization].[Intake] ([IntakeName])
        values (trim(@IntakeName));

        print 'intake "' + @IntakeName + '" added successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end
go
create or alter proc [TrainingMangerStp].stp_UpdateIntake
    @IntakeId int,
    @IntakeName nvarchar(50),
    @IsActive bit =1
as
begin
    begin try
        if not exists (select 1 from [orgnization].[Intake] where [IntakeId] = @IntakeId)
        begin
            raiserror('error: intake id not found.', 16, 1);
            return;
        end

        if len(trim(@IntakeName)) <3
        begin
            raiserror('sorry Intake name must be at least 3 letters ' ,16,1)
            return;
        end

        if exists (select 1 from [orgnization].[Intake] where [IntakeName] = @IntakeName and [IntakeId] <> @IntakeId)
        begin
            raiserror('error: another intake already has this name.', 16, 1);
            return;
        end

        update [orgnization].[Intake]
        set [IntakeName] = trim(@IntakeName),
            [isActive] = @IsActive
        where [IntakeId] = @IntakeId;

        print 'intake updated successfully.';
    end try
    begin catch
        declare  @errorMessage nvarchar(2000) = ERROR_MESSAGE() 
        raiserror(@errorMessage ,16,1)    
    end catch
end
go
create or alter proc [TrainingMangerStp].stp_DeleteIntack @IntakeId int
as
begin
    begin try
        if not exists(select 1 from [orgnization].[Intake] where [IntakeId] = @IntakeId)
        begin
            raiserror('wrong id : this branch not found',16,1)
            return
        end

        delete from [orgnization].[Intake] where [IntakeId] = @IntakeId
        print ' the opration is handel by the system triggre '

    end try
    begin catch
        declare @errorMassege nvarchar(2000) = Error_Message()
        raiserror(@errorMassege ,16,1)
    end catch
end
go
create or alter trigger [orgnization].trg_SoftDeleteIntake
on [orgnization].[Intake]
instead of delete
as
begin
    declare @id int;
    select @id = [IntakeId] from deleted;

    if exists (select 1 from [userAcc].[Student] where [IntakeId] = @id)
        or exists(select 1 from [orgnization].[IntakeTrack] where [IntakeId] = @id )
        or exists(select 1 from [Courses].[CourseInstance] where [IntakeId] = @id )

    begin
        update [orgnization].[Intake]
        set [isActive] = 0
        where [IntakeId] = @id;
        
        print 'caution: intake is linked to students and courses. status changed to inactive instead of delete.';
    end
    else 
    begin
        delete from [orgnization].[Intake] where [IntakeId] = @id;
        print 'success: intake deleted completely.';
    end
end
go
create or alter trigger [orgnization].trg_intakeTrackinactivateWhenInaactiveIntake
on [orgnization].[Intake]
after update
as
begin
    if exists (select 1 from inserted i join deleted d on i.IntakeId = d.IntakeId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @intakeid int;
        select @intakeid = IntakeId from inserted;

  
        update [orgnization].[IntakeTrack]
        set [isActive] = 0
        where [IntakeId] = @intakeid;

        print 'intake deactivated: all tracks within this intake are now inactive.';
    end
end