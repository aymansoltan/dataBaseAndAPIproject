namespace ExaminationSystem_API.Models;

public partial class VInstructorProfile
{
    public string FullName { get; set; } = null!;

    public string UserName { get; set; } = null!;

    public string UserEmail { get; set; } = null!;

    public string RoleName { get; set; } = null!;

    public int? Age { get; set; }

    public string Ssn { get; set; } = null!;

    public string PhoneNumber { get; set; } = null!;

    public decimal Salary { get; set; }

    public DateOnly? HireDate { get; set; }

    public string Specialization { get; set; } = null!;

    public string DepartmentName { get; set; } = null!;

    public DateOnly? AccountCreatedAt { get; set; }

    public string AccountStatus { get; set; } = null!;
}
