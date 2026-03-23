

namespace ExaminationSystem_API.Models;

public partial class VActiveIntakeMap
{
    public byte IntakeId { get; set; }

    public short TrackId { get; set; }

    public byte BranchId { get; set; }

    public string IntakeYear { get; set; } = null!;

    public string TrackName { get; set; } = null!;

    public string Department { get; set; } = null!;

    public string BranchName { get; set; } = null!;

    public bool? LinkStatus { get; set; }
}
