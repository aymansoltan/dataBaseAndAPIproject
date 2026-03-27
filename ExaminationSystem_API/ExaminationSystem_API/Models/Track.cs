using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class Track
{
    public short TrackId { get; set; }

    public string TrackName { get; set; } = null!;

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public DateOnly? CreatedAt { get; set; }

    public byte? DeprtmentId { get; set; }

    public virtual ICollection<CourseInstance> CourseInstances { get; set; } = new List<CourseInstance>();

    public virtual Department? Deprtment { get; set; }

    public virtual ICollection<Exam> Exams { get; set; } = new List<Exam>();

    public virtual ICollection<IntakeTrack> IntakeTracks { get; set; } = new List<IntakeTrack>();

    public virtual ICollection<Student> Students { get; set; } = new List<Student>();
}
