using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class StudentAnswer
{
    public int StudentId { get; set; }

    public short ExamId { get; set; }

    public short QuestionId { get; set; }

    public string? StudentResponse { get; set; }

    public byte? SystemGrade { get; set; }

    public byte? InstructorGrade { get; set; }

    public virtual Exam Exam { get; set; } = null!;

    public virtual Question Question { get; set; } = null!;

    public virtual Student Student { get; set; } = null!;
}
