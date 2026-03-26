namespace ExaminationSystem_API.Dto.QuestionDTO
{
    public class McqQuestionDTO : BaseQuestionDTO
    {
        public string CorrectAnswer { get; set; } // a, b, c...
        public string BestAnswer { get; set; }
        public string OptionsList { get; set; } 
    }
}
