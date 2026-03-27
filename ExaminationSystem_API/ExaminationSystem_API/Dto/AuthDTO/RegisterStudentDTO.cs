
namespace ExaminationSystem_API.Dto.AuthDTO
{
    public class RegisterStudentDTO : RegisterBaseDTO
    {
        [Required(ErrorMessage = "BranchId  is required ")]
        public byte BranchId { get; set; }
        [Required(ErrorMessage = "TrackId  is required ")]

        public short TrackId { get; set; }
    }
}
