using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VActiveIntakeMap
{
    public string IntakeYear { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string Department { get; set; } = null!;

    public string BranchName { get; set; } = null!;
}
