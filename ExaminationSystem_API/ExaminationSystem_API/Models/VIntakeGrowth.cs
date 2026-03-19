using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class VIntakeGrowth
{
    public string IntakeName { get; set; } = null!;

    public int? NumberOfTracks { get; set; }

    public DateOnly? StartDate { get; set; }
}
