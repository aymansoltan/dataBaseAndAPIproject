
namespace ExaminationSystem_API.Dto.TrackDTO
{
    public class BaseTrackDTO
    {
        [Required(ErrorMessage = "Track Name is required")]
        [MinLength(3, ErrorMessage = "Track Name must be at least 3 characters")]
        [MaxLength(40, ErrorMessage = "Track Name cannot exceed 40 characters")]
        public string TrackName { get; set; } = null!;

        [Required(ErrorMessage = "Department ID is required")]
        public byte DeptId { get; set; }
    }
}
