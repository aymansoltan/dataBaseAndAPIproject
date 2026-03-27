namespace ExaminationSystem_API.Dto.GradingDTO
{
    public class InstructorGradingDTO
    {
        public short ExamId { get; set; }
        public List<StudentGradeDTO> Grades { get; set; }
    }
}
