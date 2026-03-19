using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VStudentsFinalResult
{
    public string StudentName { get; set; } = null!;

    public string CourseName { get; set; } = null!;

    public int? PassingGrade { get; set; }

    public int? MaxGrade { get; set; }

    public byte? StudentScore { get; set; }

    public double? Percentage { get; set; }

    public string ResultStatus { get; set; } = null!;
}
