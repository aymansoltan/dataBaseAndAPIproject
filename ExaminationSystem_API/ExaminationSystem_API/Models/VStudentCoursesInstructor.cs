using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VStudentCoursesInstructor
{
    public int StudentId { get; set; }

    public short CourseId { get; set; }

    public int InstructorId { get; set; }

    public string StudentName { get; set; } = null!;

    public string CourseName { get; set; } = null!;

    public string? Coursedescription { get; set; }

    public string Branch { get; set; } = null!;

    public string Track { get; set; } = null!;

    public string Intake { get; set; } = null!;

    public short Academicyear { get; set; }

    public string InstructorName { get; set; } = null!;

    public bool? IsCourseActive { get; set; }
}
