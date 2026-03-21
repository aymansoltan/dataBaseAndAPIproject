using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VNumTrackInIntake
{
    public string IntakeName { get; set; } = null!;

    public int? TotalTracks { get; set; }
}
