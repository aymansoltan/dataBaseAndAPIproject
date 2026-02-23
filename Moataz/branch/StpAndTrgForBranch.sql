use [ExaminationSystemDB]
create proc [orgnization].stp_AddBranch @BranchName nvarchar(50)
as 
begin
    begin try
        if len(trim(@BranchName))< 3
        begin
            raiserror('branch name must be at least 3 letters' , 16,1);
            return;
        end

        insert into [orgnization].Branch (BranchName)
        values (trim(@BranchName));
        print 'Branch name added succsefully ' + @BranchName ;
    end try
    begin catch 
   
        if error_number() = 2627
        begin
          raiserror ('Error : this Branch name already exist',16,1);
          return;
        end
        else
        begin
            print 'unexepected error' + ERROR_MESSAGE();
            return;
        end
    end catch
end

create proc [orgnization].stp_UpdateBranch @BranchId int ,@BranchName nvarchar(50) , @IsActive bit = 1
as
begin
    begin try
        if not exists ( select 1 from [orgnization].[Branch] where [BranchId] =@BranchId)
        begin
            raiserror('this branch is not exists' ,16,1)
            return;
        end

        if len(trim(@BranchName)) <3
        begin
            raiserror('sorry branch name must be at least 3 letters ' ,16,1)
            return;
        end

        update [orgnization].[Branch]
        set [BranchName] =@BranchName ,[isActive] =@IsActive
        where [BranchId] = @BranchId
        print 'branch updated successfully id ' + cast(@BranchId as nvarchar(10));
    end try
    begin catch
        if ERROR_NUMBER() = 2627
        begin
            raiserror ('sorry this branch name already exists for another branch' , 16,1)
        end
        else
        begin
            declare  @errorMessage nvarchar(2000) = ERROR_MESSAGE() 
            raiserror(@errorMessage ,16,1)
        end
    end catch

end

create proc [orgnization].stp_DeleteBranch @BranchId int 
as
begin
    begin try
        if not exists(select 1 from [orgnization].[Branch] where [BranchId] = @BranchId)
        begin
            raiserror('wrong id : this branch not found',16,1)
            return
        end

        delete from [orgnization].[Branch] where [BranchId] = @BranchId
        print ' the opration is handel by the system triggre '

    end try
    begin catch
        declare @errorMassege nvarchar(2000) = Error_Message()
        raiserror(@errorMassege ,16,1)
    end catch
end

create trigger [orgnization].trg_SoftDeleteBranch
on [orgnization].[Branch]
instead of delete 
as 
begin 
    declare @Id int ;
    select @Id = [BranchId] from deleted;
    if exists(select 1 from [orgnization].[Department] where [BranchId] =@Id)
        or exists(select 1 from [userAcc].[Student] where [BranchId] =@Id)
        or exists(select 1 from [Courses].[CourseInstance] where[BranchId] =@Id)
    begin
        update [orgnization].[Branch]
        set [isActive] = 0
        where [BranchId] = @Id
        print 'cannot delete this branch because it have department and student and course but the status changed to not active'
    end
    else 
    begin
        delete from [orgnization].[Branch] where [BranchId] = @Id
        print 'this branch deleted successfully from the data base'
    end
end 


use [ExaminationSystemDB]
create  proc [orgnization].stp_ActivateBranch @BranchId int 
as
begin
    begin try
        if not exists (select 1 from [orgnization].[Branch] where [BranchId] = @BranchId)
        begin
            raiserror('Error: This branch ID was not found.', 16, 1);
            return;
        end 
        if exists(select 1 from [orgnization].[Branch] where [BranchId] = @BranchId and [isActive] = 1)
        begin
            print 'Info: This branch is already active.';
        end
        else
        begin
            update [orgnization].[Branch]
            set [isActive] = 1
            where [BranchId] = @BranchId;
            
            print 'Success: Branch has been activated.';
        end
    end try
    begin catch
        declare @errorMassege nvarchar(2000) = Error_Message()
        raiserror(@errorMassege ,16,1)
     end catch
end