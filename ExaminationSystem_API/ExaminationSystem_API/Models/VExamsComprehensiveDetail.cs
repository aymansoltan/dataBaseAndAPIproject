

namespace ExaminationSystem_API.Models;

public partial class VExamsComprehensiveDetail
{
    public short ExamId { get; set; }

    public short CourseInstanceId { get; set; }

    public byte BranchId { get; set; }

    public short TrackId { get; set; }

    public byte IntakeId { get; set; }

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
