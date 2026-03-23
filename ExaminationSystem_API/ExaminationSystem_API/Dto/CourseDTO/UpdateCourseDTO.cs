namespace ExaminationSystem_API.Dto.CourseDTO
{
    public class UpdateCourseDTO 
    {
        [Required(ErrorMessage = "Course id is required")]
        public short CourseId { get; set; }
        [StringLength(20, MinimumLength = 2, ErrorMessage = "Course name must be at least 2 letters and max length 20 letters")]
        public string? CourseName { get; set; }
        public byte? MinDegree { get; set; } 
        public byte? MaxDegree { get; set; } 
        public string? Description { get; set; } 
    }
}
