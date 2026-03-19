using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VStudentComprehensiveProfile
{
    public string FullName { get; set; } = null!;

    public string UserName { get; set; } = null!;

    public string UserEmail { get; set; } = null!;

    public string RoleName { get; set; } = null!;

    public string Gender { get; set; } = null!;

    public int? Age { get; set; }

    public string Ssn { get; set; } = null!;

    public string PhoneNumber { get; set; } = null!;

    public string BranchName { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string IntakeName { get; set; } = null!;

    public DateOnly? AccountCreatedAt { get; set; }

    public string AccountStatus { get; set; } = null!;
}
