namespace ExaminationSystem_API.Dto.AuthDTO
{
    public class UpdateInstructorDTO :BaseUpdateMemberDTO
    {
        public decimal? Salary { get; set; }
        public string? Specialization { get; set; }
        public byte? DeptId { get; set; }
        public DateOnly? HireDate { get; set; }
    }
}
