using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class VExamsComprehensiveDetail
{
    public string ExamTitle { get; set; } = null!;

    public string ExamType { get; set; } = null!;

    public string CourseName { get; set; } = null!;

    public string InstructorName { get; set; } = null!;

    public DateTime StartTime { get; set; }

    public DateTime EndTime { get; set; }

    public int? DurationMin { get; set; }

    public string BranchName { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string IntakeName { get; set; } = null!;

    public string ExamStatus { get; set; } = null!;
}
