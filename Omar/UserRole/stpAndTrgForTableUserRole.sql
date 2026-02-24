CREATE TRIGGER trg_PreventModifyUserRole
ON userAcc.UserRole
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    THROW 50001, 'UserRole is a static system table and cannot be modified.', 1;
END;