using System.ComponentModel.DataAnnotations;

namespace ExaminationSystem_API.Dto.AuthDTO
{
    public class RegisterInstructorDTO :RegisterBaseDTO
    {
        [Required(ErrorMessage = "Salary  is required ")]
        public decimal Salary { get; set; }

        [Required(ErrorMessage = "Specialization  is required ")]
        [StringLength(50, MinimumLength = 1, ErrorMessage = "Specialization must be at least 1 letters and max length 50 letters")]
        public string Specialization { get; set; } = null!;

        [Required(ErrorMessage = "DeptId  is required ")]

        public byte DeptId { get; set; }
        [Required(ErrorMessage = "HireDate  is required ")]
        public DateTime? HireDate { get; set; }
    }
}
