using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class Exam
{
    public short ExamId { get; set; }

    public string ExamTitle { get; set; } = null!;

    public string ExamType { get; set; } = null!;

    public DateTime StartTime { get; set; }

    public DateTime EndTime { get; set; }

    public int? DurationMinutes { get; set; }

    public short CourseInstanceId { get; set; }

    public byte BranchId { get; set; }

    public short TrackId { get; set; }

    public byte IntakeId { get; set; }

    public bool? IsDeleted { get; set; }

    public byte? TotalGrade { get; set; }

    public virtual Branch Branch { get; set; } = null!;

    public virtual CourseInstance CourseInstance { get; set; } = null!;

    public virtual Intake Intake { get; set; } = null!;

    public virtual ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();

    public virtual ICollection<StudentExamResult> StudentExamResults { get; set; } = new List<StudentExamResult>();

    public virtual Track Track { get; set; } = null!;

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
}
