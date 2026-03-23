
namespace ExaminationSystem_API.Dto.AuthDTO
{
    public class BaseUpdateMemberDTO
    {
        [Required(ErrorMessage = "UserId is required")]
        public int UserId { get; set; }

        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public char? Gender { get; set; }
        public DateTime? BirthDate { get; set; }

        public string? Address { get; set; }

        [StringLength(11, MinimumLength = 11, ErrorMessage = "Phone must be 11 digits")]
        public string? Phone { get; set; }

        [StringLength(14, MinimumLength = 14, ErrorMessage = "NationalId must be 14 digits")]
        public string? NationalId { get; set; }

    }
}
