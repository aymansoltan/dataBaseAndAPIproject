using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class Question
{
    public short QuestionId { get; set; }

    public string QuestionText { get; set; } = null!;

    public string QuestionType { get; set; } = null!;

    public string? CorrectAnswer { get; set; }

    public string BestAnswer { get; set; } = null!;

    public byte? Points { get; set; }

    public short CourseId { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual Course Course { get; set; } = null!;

    public virtual ICollection<QuestionOption> QuestionOptions { get; set; } = new List<QuestionOption>();

    public virtual ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();

    public virtual ICollection<Exam> Exams { get; set; } = new List<Exam>();
}
