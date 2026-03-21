using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VDepartmentBranchSummary
{
    public byte DeptId { get; set; }

    public byte BranchId { get; set; }

    public string DepartmentName { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateOnly? CreationTime { get; set; }

    public string BranchName { get; set; } = null!;
}
