namespace ExaminationSystem_API.Dto.StudentAnswerDTO
{
    public class SubmitExamDTO
    {
        public short ExamId { get; set; }
        public List<StudentAnswerDTO> Answers { get; set; }
    }
}
