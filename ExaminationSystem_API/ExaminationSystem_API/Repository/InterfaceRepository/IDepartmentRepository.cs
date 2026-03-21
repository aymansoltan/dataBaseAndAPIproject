namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IDepartmentRepository :IGenericRepository<Department>
    {
        Task AddDepartmentWithStoredAsync(string name, int BranchID);
        Task UpdateDepartmentWithStoredAsync(int DeptId, string name, int BranchID);
        Task DeleteDepartmentWithStoredAsync(int DeptId);
    }
}
