using ExaminationSystem_API.Dto.DepartmentDTO;
using ExaminationSystem_API.Helper;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IDepartmentService
    {
        Task AddDepartmentAsync(AddDepartmentDTO departmentDTO);
        Task UpdateDepartmentAsync(UpdateDepartmentDTO departmentDTO);
        Task DeleteDepartmentAsync(int id);
        Task<DepartmentReadByIDDTO> GetDepartmentByID(int id);
        Task<PaginatedList<DepartmentReadAll>> GetAllDepartment(string? searchTerm, int pageNumber, int pageSize);
        Task<IEnumerable<DepartmentLookupDTO>> GetDepartmentLookupAsync();
    }
}
