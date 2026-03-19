using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class CourseInstance
{
    public short CourseInstanceId { get; set; }

    public short CourseId { get; set; }

    public int InstructorId { get; set; }

    public byte BranchId { get; set; }

    public short TrackId { get; set; }

    public byte IntakeId { get; set; }

    public short AcademicYear { get; set; }

    public bool? IsDeleted { get; set; }

    public bool? IsActive { get; set; }

    public virtual Branch Branch { get; set; } = null!;

    public virtual Course Course { get; set; } = null!;

    public virtual ICollection<Exam> Exams { get; set; } = new List<Exam>();

    public virtual Instructor Instructor { get; set; } = null!;

    public virtual Intake Intake { get; set; } = null!;

    public virtual Track Track { get; set; } = null!;
}
