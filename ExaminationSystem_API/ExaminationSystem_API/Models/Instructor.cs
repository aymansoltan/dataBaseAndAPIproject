using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class Instructor
{
    public int InstructorId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public DateOnly? BirthDate { get; set; }

    public int? Age { get; set; }

    public string? InsAddress { get; set; }

    public string Phone { get; set; } = null!;

    public string NationalId { get; set; } = null!;

    public decimal Salary { get; set; }

    public DateOnly? HireDate { get; set; }

    public string Specialization { get; set; } = null!;

    public int UserId { get; set; }

    public byte DeptId { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual ICollection<CourseInstance> CourseInstances { get; set; } = new List<CourseInstance>();

    public virtual Department Dept { get; set; } = null!;

    public virtual UserAccount User { get; set; } = null!;
}
