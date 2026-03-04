use [ExaminationSystemDB]
go
create proc [TrainingMangerStp].stp_AddDepartment 
    @Deptname nvarchar(50), 
    @BranchId int
as
begin
    begin try
        if len(trim(@Deptname)) < 2
        begin
            raiserror('Department name must be at least 2 characters long.', 16, 1);
            return;
        end

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @BranchId)
        begin
            raiserror('error: this branch id does not exist.', 16, 1);
            return;
        end

        if exists (select 1 from [orgnization].[Department] where [DeptName] = @Deptname and [BranchId] = @BranchId)
        begin
            raiserror('this department name already exists in this branch.', 16, 1);
            return;
        end

        insert into [orgnization].[Department]([DeptName], [BranchId])
        values (trim(@Deptname), @BranchId);

        print 'Department "' + @Deptname + '" added successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end
go
create trigger [orgnization].trg_CheckBranchStatusBeforeInsert
on [orgnization].[Department]
after insert
as
begin

    if exists (
        select 1 
        from inserted i
        join [orgnization].[Branch] b on i.branchid = b.[BranchId]
        where b.[isActive] = 0
    )
    begin
        rollback transaction;
        raiserror('operation cancelled: cannot add a department to an inactive branch.', 16, 1);
    end
end
go
create proc [TrainingMangerStp].stp_UpdateDepartment
    @DeptId int,
    @DeptName nvarchar(50),
    @BranchId int

as
begin
    begin try
        if not exists (select 1 from [orgnization].[Department] where [DeptId] = @DeptId)
        begin
            raiserror('error: Department id not found.', 16, 1);
            return;
        end

        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @BranchId and [isActive] = 1)
        begin
            raiserror('error: Branch id not found or is inactive.', 16, 1);
            return;
        end

        if exists (select 1 from [orgnization].[Department] 
                   where [DeptName] = @DeptName and BranchId = @BranchId and DeptId <> @DeptId)
        begin
            raiserror('this department name already exists in this branch.', 16, 1);
            return;
        end

        update [orgnization].Department
        set DeptName = trim(@DeptName),
            BranchId = @BranchId
        where DeptId = @DeptId;

        print 'Department updated successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end
go

create proc [TrainingMangerStp].stp_DeleteDepartment
    @DeptId int

as
begin
    begin try
        if not exists (select 1 from [orgnization].[Department] where [DeptId] = @DeptId)
        begin
            raiserror('error: Department id not found.', 16, 1);
            return;
        end

        delete from [orgnization].[Department] where [DeptId] = @DeptId;
        print 'operation completed successfully.';
    end try
    begin catch
        declare @errmsg nvarchar(2000) = error_message();
        raiserror(@errmsg, 16, 1);
    end catch
end

go
create trigger [orgnization].trg_SoftDeleteDepartment
on [orgnization].[Department]
instead of delete
as
begin
    declare @Id int;
    select @Id = [DeptId] from deleted;

    if exists (select 1 from [orgnization].[Track] where[DeprtmentId]  = @Id)
        or exists (select 1 from [userAcc].[Instructor]  where [DeptId] = @Id)
    begin
        update [orgnization].[Department]
        set[isActive]  = 0
        where [DeptId] = @Id;
        
        print 'caution: Department linked to other data. status changed to inactive instead of deletion.';
    end
    else 
    begin
        delete from [orgnization].[Department] where [DeptId] = @Id;
        print 'success: Department deleted from database.';
    end
end
go
create trigger [orgnization].trg_inactivateTracksWhenInActiveDerpartment
on [orgnization].[Department]
after update
as
begin
  
    if exists (select 1 from inserted i join deleted d on i.DeptId = d.DeptId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @deptid int;
        select @deptid = DeptId from inserted;

        update [orgnization].[Track]
        set [isActive] = 0
        where [DeprtmentId]  = @deptid;

        print 'department deactivated: all related tracks have been notified.';
    end
end
