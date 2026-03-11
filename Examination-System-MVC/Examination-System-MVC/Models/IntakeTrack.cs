using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class IntakeTrack
{
    public byte IntakeId { get; set; }

    public short TrackId { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public DateOnly? CreatedAt { get; set; }

    public virtual Intake Intake { get; set; } = null!;

    public virtual Track Track { get; set; } = null!;
}
