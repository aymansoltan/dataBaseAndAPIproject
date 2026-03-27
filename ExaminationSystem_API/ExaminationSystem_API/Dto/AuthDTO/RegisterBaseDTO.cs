
namespace ExaminationSystem_API.Dto.AuthDTO
{
    public enum TargetType
    {
        std,
        ins
    }
    public class RegisterBaseDTO
    {
        [Required(ErrorMessage = "user name is required ")]
        [StringLength(50, MinimumLength = 10, ErrorMessage = "user name must be at least 10 letters and max length 50 letters")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "Email is required ")]
        [EmailAddress(ErrorMessage = "Email must contain @")]
        [StringLength(100, MinimumLength = 10, ErrorMessage = "Email must be at least 10 letters and max length 100 letters")]
        public string Email { get; set; }

        [Required(ErrorMessage = " Password is required ")]
        [StringLength(250, MinimumLength = 8, ErrorMessage = "Password must be at least 8 letters and max length 250 letters")]
        public string Password { get; set; }


        [Required(ErrorMessage = "Target Type is required and must be std or ins ")]
        public TargetType TargetType { get; set; }

        [Required(ErrorMessage = "First Name is required ")]
        [StringLength(20, MinimumLength = 2, ErrorMessage = "First name must be at least 2 letters and max length 20 letters")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Last name is required ")]
        [StringLength(20, MinimumLength = 2, ErrorMessage = "Last name must be at least 2 letters and max length 20 letters")]
        public string LastName { get; set; }

        [Required(ErrorMessage = "Gender is required and must be one char M or F ")]
        [RegularExpression("^[MFmf]$")]
        public char Gender { get; set; }

        [Required(ErrorMessage = "Birth Date is required ")]
        public DateTime BirthDate { get; set; }


        [Required(ErrorMessage = "Address is required ")]
        [StringLength(150, MinimumLength = 10, ErrorMessage = "Address must be at least 10 letters and max length 150 letters")]
        public string Address { get; set; }

        [Required(ErrorMessage = "Phone  is required ")]
        [StringLength(11, MinimumLength = 11, ErrorMessage = "Phone must be 11 number")]
        public string Phone { get; set; }

        [Required(ErrorMessage = "National Id is required ")]
        [StringLength(14, MinimumLength = 14, ErrorMessage = "National Id must be length 14 letters")]
        public string NationalId { get; set; }
    }
}
