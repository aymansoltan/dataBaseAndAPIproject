using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VQuestionBankSummary
{
    public short CourseId { get; set; }

    public string CourseName { get; set; } = null!;

    public string QuestionType { get; set; } = null!;

    public int? TotalQuestions { get; set; }

    public double? AveragePoints { get; set; }

    public int? TotalPointsAvailable { get; set; }
}
