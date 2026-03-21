using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VStudentsFinalResult
{
    public int StudentId { get; set; }

    public short ExamId { get; set; }

    public short CourseInstanceId { get; set; }

    public byte BranchId { get; set; }

    public short TrackId { get; set; }

    public string StudentName { get; set; } = null!;

    public string CourseName { get; set; } = null!;

    public int? PassingGrade { get; set; }

    public int? MaxGrade { get; set; }

    public byte? StudentScore { get; set; }

    public double? Percentage { get; set; }

    public string ResultStatus { get; set; } = null!;

    public DateOnly? ExamDate { get; set; }
}
