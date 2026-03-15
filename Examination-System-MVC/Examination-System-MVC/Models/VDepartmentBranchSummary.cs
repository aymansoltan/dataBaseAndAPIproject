

namespace Examination_System_MVC.Models;

public partial class VDepartmentBranchSummary
{
    public string DepartmentName { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateOnly? CreationTime { get; set; }

    public string BranchName { get; set; } = null!;
}
