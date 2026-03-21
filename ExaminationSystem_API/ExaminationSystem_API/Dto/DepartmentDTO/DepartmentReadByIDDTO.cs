namespace ExaminationSystem_API.Dto.DepartmentDTO
{
    public class DepartmentReadByIDDTO : DepartmentReadAll
    {
        public bool IsActive { get; set; }

        public DateOnly? CreatedAt { get; set; }

        public byte BranchId { get; set; }

    }
}
