
namespace Examination_System_MVC.Models;

public partial class StudentExamResult
{
    public int StudentId { get; set; }

    public short ExamId { get; set; }

    public byte? TotalGrade { get; set; }

    public bool? IsPassed { get; set; }

    public virtual Exam Exam { get; set; } = null!;

    public virtual Student Student { get; set; } = null!;
}
