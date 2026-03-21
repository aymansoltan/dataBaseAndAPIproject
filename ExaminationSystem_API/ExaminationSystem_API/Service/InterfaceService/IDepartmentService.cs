using ExaminationSystem_API.Dto.DepartmentDTO;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IDepartmentService
    {
        Task AddDepartmentAsync(AddDepartmentDTO departmentDTO);
        Task UpdateDepartmentAsync(UpdateDepartmentDTO departmentDTO);
    }
}
