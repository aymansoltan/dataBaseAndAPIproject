namespace ExaminationSystem_API.Dto.CourseInstanceDTO
{
    public class UpdateCourseInstanceDTO
    {
        [Required]
        public short CourseInstanceId { get; set; }
        public short? CourseId { get; set; }
        public int? InstructorId { get; set; }
        public byte? BranchId { get; set; }
        public short? TrackId { get; set; }
        public short? AcademicYear { get; set; }
    }
}
