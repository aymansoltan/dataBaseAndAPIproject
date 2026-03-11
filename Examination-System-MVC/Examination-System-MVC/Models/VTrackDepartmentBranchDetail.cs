using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class VTrackDepartmentBranchDetail
{
    public string TrackName { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateOnly? CreationTime { get; set; }

    public string DepartmentName { get; set; } = null!;

    public string BranchName { get; set; } = null!;
}
