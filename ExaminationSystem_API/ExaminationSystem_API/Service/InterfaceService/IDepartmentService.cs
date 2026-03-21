using ExaminationSystem_API.Dto.DepartmentDTO;
using ExaminationSystem_API.Helper;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IDepartmentService
    {
        Task AddDepartmentAsync(AddDepartmentDTO departmentDTO);
        Task UpdateDepartmentAsync(UpdateDepartmentDTO departmentDTO);
        Task DeleteDepartmentAsync(byte id);
        Task<DepartmentReadByIDDTO> GetDepartmentByID(byte id);
        Task<PaginatedList<DepartmentReadAll>> GetAllDepartment(string? searchTerm, int pageNumber, int pageSize);
        Task<IEnumerable<DepartmentLookupDTO>> GetDepartmentLookupAsync();
    }
}
