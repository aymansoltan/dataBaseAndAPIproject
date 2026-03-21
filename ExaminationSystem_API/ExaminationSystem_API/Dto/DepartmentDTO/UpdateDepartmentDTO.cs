using System.ComponentModel.DataAnnotations;

namespace ExaminationSystem_API.Dto.DepartmentDTO
{
    public class UpdateDepartmentDTO :BaseDepartmentDTO
    {
        [Required(ErrorMessage = "Department ID is required for update")]
        public int DeptId { get; set; }
    }
}
