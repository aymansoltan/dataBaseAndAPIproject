namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IDepartmentRepository :IGenericRepository<Department>
    {
        Task AddDepartmentWithStoredAsync(string name, byte BranchID);
        Task UpdateDepartmentWithStoredAsync(byte DeptId, string name, byte BranchID);
        Task DeleteDepartmentWithStoredAsync(byte DeptId);
    }
}
