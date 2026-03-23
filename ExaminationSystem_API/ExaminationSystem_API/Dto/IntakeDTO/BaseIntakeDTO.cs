
namespace ExaminationSystem_API.Dto.IntakeDTO
{
    public class BaseIntakeDTO
    {
        [Required(ErrorMessage = "the intake name is required")]
        [StringLength(10, MinimumLength = 3, ErrorMessage = "intake name must be between 3 and 15 letters")]
        [Display(Name = "intake name")]
        public string IntakeName { get; set; } 
    }
}
