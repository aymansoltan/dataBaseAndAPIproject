namespace ExaminationSystem_API.Dto.ExamDto
{
    public class RandomExamDTO :BaseExamDTO
    {
        public byte QuestionCount { get; set; }
        public byte? McqCount { get; set; }
        public byte? TfCount { get; set; }
        public byte? TextCount { get; set; }
    }
}
