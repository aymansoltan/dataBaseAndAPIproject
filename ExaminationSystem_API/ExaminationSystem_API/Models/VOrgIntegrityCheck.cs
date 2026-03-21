using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VOrgIntegrityCheck
{
    public byte BranchId { get; set; }

    public string BranchName { get; set; } = null!;

    public int? TotalDepartments { get; set; }

    public int? TotalTracks { get; set; }

    public int? TotalActiveIntakes { get; set; }
}
