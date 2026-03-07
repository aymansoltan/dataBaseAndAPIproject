use [ExaminationSystemDB]
go
create or alter proc [TrainingMangerStp].stp_AddBranch @BranchName varchar(15)
as 
begin
    set nocount on;
    begin try
        if len(trim(@BranchName))< 3
           throw 50001,'Error: Branch name must be at least 3 characters long.',1;      

        insert into [Branch] (BranchName)
        values (lower(trim(@BranchName)));
        select SCOPE_IDENTITY() as NewBranchId , 1 as Success ,'Branch added successfully' as Message;
    end try
    begin catch 
   
        if error_number() in (2627, 2601)
            throw 50002,'Error: A branch with this name already exists. Please choose a different name.',1; 
        else
            throw;
    end catch
end
go


create or alter proc [TrainingMangerStp].stp_UpdateBranch @BranchId tinyint  ,@BranchName varchar(15) 
as
begin
    set nocount on;
    begin try

        if not exists ( select 1 from [Branch] where [BranchId] =@BranchId and [isDeleted] = 0)
            throw 50003, 'Error: Branch not found or it has been deleted.', 1;  
         
        if len(trim(@BranchName)) <3
            throw 50001,'Error: Branch name must be at least 3 characters long.',1;

        update [Branch]
        set [BranchName] =@BranchName 
        where [BranchId] = @BranchId   
        select @BranchId as UpdatedBranchId , 1 as Success, 'Branch updated successfully' as Message;
    end try
    begin catch
        if error_number() in (2627, 2601)   
            throw 50002,'Error: A branch with this name already exists. Please choose a different name.',1;
        else
          throw;
    end catch

end
go

create or alter proc [TrainingMangerStp].stp_DeleteBranch @BranchId tinyint 
as
begin
    set nocount on;
    begin try
        if not exists(select 1 from [Branch] where [BranchId] = @BranchId and [isDeleted] = 0)
            throw 50003, 'Error: Branch not found or it has been deleted.', 1;

        delete from [Branch] where [BranchId] = @BranchId
        select 1 as Success , 'Branch deleted successfully.' as Message;
    end try
    begin catch
        throw;
    end catch
end
go


create  or alter trigger [orgnization].trg_SoftDeleteBranch
on [Branch]
instead of delete 
as 
begin 
    set nocount on;
    declare @BranchId tinyint ;
    select @BranchId = [BranchId] from deleted;

    if exists(select 1 from [Department] where [BranchId] =@BranchId)
        or exists(select 1 from [Students] where [BranchId] =@BranchId)
        or exists(select 1 from [CourseInstance] where[BranchId] =@BranchId)
    begin
        update  [Branch]
        set [isActive] = 0 , [isDeleted] = 1
        where [BranchId] = @BranchId
    end
    else 
    begin
        delete from  [Branch]where [BranchId] = @BranchId;
    end
end 
go


create or alter proc [TrainingMangerStp].stp_ActivateBranch @BranchId tinyint 
as
begin
    set nocount on;
    begin try
        if not exists (select 1 from  [Branch] where [BranchId] = @BranchId and [isDeleted] = 0)
            throw 50003, 'Error: Branch not found or it has been deleted.', 1;

        if exists(select 1 from  [Branch] where [BranchId] = @BranchId and [isActive] = 1)
            throw 50004, 'Error: Branch is already active.', 1;
        else
        begin
            update [Branch]
            set [isActive] = 1
            where [BranchId] = @BranchId;
            
            update [Department]
            set [isActive] =1
            where [BranchId] =@BranchId
            select 1 as Success, 'Branch activated and its related departments have been synchronized.' as Message;   
        end
    end try
    begin catch
        throw;
     end catch
end
go
create or alter  trigger [orgnization].trg_inactivateDepartmentWhenInActiveBranch
on [Branch]
after update
as
begin
    set nocount on;
    
    if exists (select 1 from inserted i join deleted d on i.BranchId = d.BranchId where i.isActive = 0 and d.isActive = 1)
    begin
        declare @branchid tinyint;
        select @branchid = BranchId from inserted;

        update [Department]
        set [isActive] = 0
        where [BranchId] = @branchid;
    end
end

