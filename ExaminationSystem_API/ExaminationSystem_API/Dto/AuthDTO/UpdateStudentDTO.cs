namespace ExaminationSystem_API.Dto.AuthDTO
{
    public class UpdateStudentDTO : BaseUpdateMemberDTO
    {
        public byte? BranchId { get; set; }
        public short? TrackId { get; set; }
        public byte? IntakeId { get; set; }
    }
}
