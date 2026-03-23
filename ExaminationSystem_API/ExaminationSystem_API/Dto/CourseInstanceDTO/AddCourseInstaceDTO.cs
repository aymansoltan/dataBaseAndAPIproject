using ExaminationSystem_API.Models;

namespace ExaminationSystem_API.Dto.CourseInstanceDTO
{
    public class AddCourseInstaceDTO
    {
        [Required(ErrorMessage ="Course id is required")]
        public short CourseId { get; set; }

        [Required(ErrorMessage = "Instructor id is required")]
        public int InstructorId { get; set; }

        [Required(ErrorMessage = "Branch id is required")]
        public byte BranchId { get; set; }

        [Required(ErrorMessage = "Track id is required")]
        public short TrackId { get; set; }

        [Required(ErrorMessage = "Academic Year is required")]
        public short AcademicYear { get; set; }

    }
}
