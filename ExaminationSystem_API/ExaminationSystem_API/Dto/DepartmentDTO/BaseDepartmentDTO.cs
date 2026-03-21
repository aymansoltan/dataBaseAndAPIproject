using System.ComponentModel.DataAnnotations;

namespace ExaminationSystem_API.Dto.DepartmentDTO
{
    public class BaseDepartmentDTO
    {
        [Required(ErrorMessage = "Department Name Required")]
        [StringLength(20, MinimumLength = 2, ErrorMessage = "Name must be at least 2 letters and max length 20 letters")]
        public string DeptName { get; set; }

        [Required(ErrorMessage = "must select branch")]
        public byte BranchId { get; set; }
    }
}
