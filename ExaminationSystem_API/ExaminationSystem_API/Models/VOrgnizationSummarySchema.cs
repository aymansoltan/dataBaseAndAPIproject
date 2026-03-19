using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VOrgnizationSummarySchema
{
    public string BranchName { get; set; } = null!;

    public string DepartmentName { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string IntakeName { get; set; } = null!;

    public string TrackStatus { get; set; } = null!;
}
