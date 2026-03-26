namespace ExaminationSystem_API.Dto.QuestionDTO
{
    public class TfQuestionDTO :BaseQuestionDTO
    {
        public string CorrectAnswer { get; set; } // true, false
        public string BestAnswer { get; set; }
    }
}
