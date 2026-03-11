using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class VQuestionBankSummary
{
    public string CourseName { get; set; } = null!;

    public string QuestionType { get; set; } = null!;

    public int? TotalQuestions { get; set; }

    public double? AveragePoints { get; set; }
}
