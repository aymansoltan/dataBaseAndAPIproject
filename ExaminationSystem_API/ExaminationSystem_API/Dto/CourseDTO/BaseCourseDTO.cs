namespace ExaminationSystem_API.Dto.CourseDTO
{
    public class BaseCourseDTO
    {
        [Required(ErrorMessage = "Course name is required ")]
        [StringLength(20, MinimumLength = 2, ErrorMessage = "Course name must be at least 2 letters and max length 20 letters")]
        public string CourseName { get; set; }
        [Required(ErrorMessage = "Min Degree is required and must be less than 250 ")]

        public byte MinDegree { get; set; }
        [Required(ErrorMessage = "Max Degree is required  and must be less than 250")]
        public byte MaxDegree { get; set; }
        [StringLength(500, MinimumLength = 10, ErrorMessage = "user name must be at least 10 letters and max length 50 letters")]
        public string? Description { get; set; } = null!;
    }
}
