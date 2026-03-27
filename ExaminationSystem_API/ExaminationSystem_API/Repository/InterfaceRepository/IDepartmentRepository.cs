namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IDepartmentRepository : IGenericRepository<Department>
    {
        Task AddDepartmentWithStoredAsync(AddDepartmentDTO dto);
        Task UpdateDepartmentWithStoredAsync(UpdateDepartmentDTO dto);
        Task DeleteDepartmentWithStoredAsync(byte DeptId);
    }
}
