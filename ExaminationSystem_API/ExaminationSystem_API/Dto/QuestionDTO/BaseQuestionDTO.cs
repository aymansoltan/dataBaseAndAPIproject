namespace ExaminationSystem_API.Dto.QuestionDTO
{
    public class BaseQuestionDTO
    {
        public string QuestionText { get; set; }
        public int CourseId { get; set; }
        public byte Points { get; set; } = 1;
    }
}
