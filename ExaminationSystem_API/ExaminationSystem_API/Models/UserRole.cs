

namespace ExaminationSystem_API.Models;

public partial class UserRole
{
    public byte RoleId { get; set; }

    public UserRole RoleName { get; set; }

    public virtual ICollection<UserAccount> UserAccounts { get; set; } = new List<UserAccount>();
}
