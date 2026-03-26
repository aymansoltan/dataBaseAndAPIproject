namespace ExaminationSystem_API.Dto.ExamDto
{
    public class BaseExamDTO
    {
        public string ExamTitle { get; set; }
        public string ExamType { get; set; } = "regular";
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public short CourseInstanceId { get; set; }
        public byte BranchId { get; set; }
        public short TrackId { get; set; }
    }
}
