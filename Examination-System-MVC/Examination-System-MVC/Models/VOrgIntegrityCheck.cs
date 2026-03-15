

namespace Examination_System_MVC.Models;

public partial class VOrgIntegrityCheck
{
    public string BranchName { get; set; } = null!;

    public int? TotalDepartments { get; set; }

    public int? TotalTracks { get; set; }

    public int? TotalActiveIntakes { get; set; }
}
