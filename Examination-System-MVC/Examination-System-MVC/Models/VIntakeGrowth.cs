using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class VIntakeGrowth
{
    public string IntakeName { get; set; } = null!;

    public int? NumberOfTracks { get; set; }

    public DateOnly? StartDate { get; set; }
}
