create trigger  trg_PreventModifyUserRole
on [userAcc].[UserRole]
instead of insert , update , delete
as 
begin
    throw 50001, 'UserRole is a static system table and cannot be modified.', 1;
end
