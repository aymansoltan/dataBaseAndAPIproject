using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class Course
{
    public short CourseId { get; set; }

    public string CourseName { get; set; } = null!;

    public string? CourseDescription { get; set; }

    public int? MinDegree { get; set; }

    public int? MaxDegree { get; set; }

    public bool? IsDeleted { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<CourseInstance> CourseInstances { get; set; } = new List<CourseInstance>();

    public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
}
