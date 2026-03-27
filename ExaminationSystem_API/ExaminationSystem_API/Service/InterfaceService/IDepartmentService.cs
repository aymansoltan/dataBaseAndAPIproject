
namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IDepartmentService
    {
        Task AddDepartmentAsync(AddDepartmentDTO dto);
        Task UpdateDepartmentAsync(UpdateDepartmentDTO dto);
        Task DeleteDepartmentAsync(byte id);
        Task<DepartmentReadByIDDTO> GetDepartmentByID(byte id);
        Task<PaginatedList<DepartmentReadAll>> GetAllDepartment(string? searchTerm, int pageNumber, int pageSize);
        Task<IEnumerable<DepartmentLookupDTO>> GetDepartmentLookupAsync();
    }
}
