using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class VTrackIntakeDetail
{
    public string IntakeName { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string OverallStatus { get; set; } = null!;

    public DateOnly? TrackCreationTime { get; set; }

    public bool? IsIntakeActive { get; set; }

    public bool? IsTrackActive { get; set; }
}
