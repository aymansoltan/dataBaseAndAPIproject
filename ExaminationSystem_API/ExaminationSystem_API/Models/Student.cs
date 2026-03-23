

namespace ExaminationSystem_API.Models;

public partial class Student
{
    public int StudentId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Gender { get; set; } = null!;

    public DateOnly BirthDate { get; set; }

    public string StuAddress { get; set; } = null!;

    public string Phone { get; set; } = null!;

    public string NationalId { get; set; } = null!;

    public int? Age { get; set; }

    public int UserId { get; set; }

    public byte BranchId { get; set; }

    public byte IntakeId { get; set; }

    public short TrackId { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual Branch Branch { get; set; } = null!;

    public virtual Intake Intake { get; set; } = null!;

    public virtual ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();

    public virtual ICollection<StudentExamResult> StudentExamResults { get; set; } = new List<StudentExamResult>();

    public virtual Track Track { get; set; } = null!;

    public virtual UserAccount User { get; set; } = null!;
}
