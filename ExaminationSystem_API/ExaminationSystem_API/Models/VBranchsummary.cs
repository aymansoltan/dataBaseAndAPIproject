using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VBranchsummary
{
    public string? BranchName { get; set; }

    public string Status { get; set; } = null!;

    public DateOnly? CreationTime { get; set; }
}
