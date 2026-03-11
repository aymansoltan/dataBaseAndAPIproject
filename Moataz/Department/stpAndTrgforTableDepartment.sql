use [ExaminationSystemDB]
go
create or alter proc [TrainingMangerStp].stp_AddDepartment 
    @Deptname varchar(20), 
    @BranchId tinyint
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Branch] where [BranchId] = @BranchId and [isActive] = 1 and [isDeleted] = 0)
            throw 50002, 'Error: Branch not found, inactive, or it has been deleted.', 1;

        if len(trim(@Deptname)) < 2
            throw 50001,'Error: Department name must be at least 2 characters long.',1;
         
        if exists (select 1 from [Department] where [DeptName] = @Deptname and [BranchId] = @BranchId and [isDeleted] = 0 )
            throw 50003, 'Error: A department with this name already exists in the specified branch.', 1;


        insert into [Department] ([DeptName], [BranchId])
        values (trim(@Deptname), @BranchId);
        select SCOPE_IDENTITY() as NewDepartmentId , 1 as Success, 'Department added successfully' as Message;
        
    end try
    begin catch
        throw;
    end catch
end

create or alter proc [TrainingMangerStp].stp_UpdateDepartment
    @DeptId tinyint,
    @DeptName varchar(20),
    @BranchId tinyint
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Department] where [DeptId] = @DeptId and [isDeleted] = 0 and [isActive] = 1)
            throw 50004, 'Error: Department not found or it has been deleted.', 1;

        if not exists (select 1 from [Branch] where [BranchId] = @BranchId and [isActive] = 1 and [isDeleted] = 0)
            throw 50002, 'Error: Branch not found, inactive, or it has been deleted.', 1;
            

        if exists (select 1 from [Department] where [DeptName] = @DeptName and BranchId = @BranchId and DeptId <> @DeptId)
            throw 50003, 'Error: A department with this name already exists in the specified branch.', 1;

        update [Department]
        set DeptName = trim(@DeptName),
            BranchId = @BranchId
        where DeptId = @DeptId;
        select @DeptId as UpdateDepartmentId , 1 as Success , 'Department Updated successfully' as Message;
    end try
    begin catch
        throw;
    end catch
end
go

create or alter proc [TrainingMangerStp].stp_DeleteDepartment
    @DeptId tinyint 
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from [Department] where [DeptId] = @DeptId and [isDeleted] = 0)
            throw 50004, 'Error: Department not found or it has been deleted.', 1;

        delete from [Department]where [DeptId] = @DeptId;
        select 1 as Success , 'Department deleted successfully.' as Message;
    end try
    begin catch
        throw;
    end catch
end

create or alter trigger [orgnization].trg_SoftDeleteDepartment
on [orgnization].[Department]
instead of delete
as
begin
    set nocount on;
    declare @DeptId tinyint;
    select @DeptId = [DeptId] from deleted;

    if exists (select 1 from [Track] where[DeprtmentId]  = @DeptId)
        or exists (select 1 from [Instructors]  where [DeptId] = @DeptId)
    begin
        update [Department]
        set[isActive]  =  0 , [isDeleted] = 1
        where [DeptId] = @DeptId;       
    end
    else 
    begin
        delete from [Department] where [DeptId] = @DeptId;
    end
end

go
create or alter trigger [orgnization].trg_CheckBranchStatusBeforeInsert
on [orgnization].[Department]
after insert
as
begin
    set nocount on;
    if exists (
        select 1 
        from inserted i
        join [Branch] b on i.[BranchId] = b.[BranchId]
        where b.[isActive] = 0 or b.[isDeleted] = 1
    )
    begin
        rollback transaction;
        throw 50002, 'Error: Cannot add department to an inactive or deleted branch.', 1;
    end
end
go


go

go
create trigger [orgnization].trg_inactivateTracksWhenInActiveDerpartment
on [orgnization].[Department]
after update
as
begin
    set nocount on;
    if exists (select 1 from inserted i join deleted d on i.DeptId = d.DeptId 
               where i.isActive = 0 and d.isActive = 1)
    begin
        declare @deptid tinyint;
        select @deptid = DeptId from inserted;

        update [Track]
        set [isActive] = 0 
        where [DeprtmentId]  = @deptid;

    end
end
