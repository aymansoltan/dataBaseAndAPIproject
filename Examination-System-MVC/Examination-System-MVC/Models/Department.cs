

namespace Examination_System_MVC.Models;

public partial class Department
{
    public byte DeptId { get; set; }

    public string DeptName { get; set; } = null!;

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public DateOnly? CreatedAt { get; set; }

    public byte? BranchId { get; set; }

    public virtual Branch? Branch { get; set; }

    public virtual ICollection<Instructor> Instructors { get; set; } = new List<Instructor>();

    public virtual ICollection<Track> Tracks { get; set; } = new List<Track>();
}
