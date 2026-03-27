using System;
using System.Collections.Generic;

namespace ExaminationSystem_API.Models;

public partial class UserRole
{
    public byte RoleId { get; set; }

    public string RoleName { get; set; } = null!;

    public virtual ICollection<UserAccount> UserAccounts { get; set; } = new List<UserAccount>();
}
