
namespace ExaminationSystem_API.Models;

public partial class UserAccount
{
    public int UserId { get; set; }

    public string UserName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string UserPassword { get; set; } = null!;

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }

    public DateOnly? CreatedAt { get; set; }

    public byte? RoleId { get; set; }

    public virtual Instructor? Instructor { get; set; }

    public virtual UserRole? Role { get; set; }

    public virtual Student? Student { get; set; }
}
