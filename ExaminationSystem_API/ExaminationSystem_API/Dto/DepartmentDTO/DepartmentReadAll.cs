namespace ExaminationSystem_API.Dto.DepartmentDTO
{
    public class DepartmentReadAll
    {
        public byte DeptId { get; set; }

        public string DeptName { get; set; } = null!;
        public string BranchName { get; set; } = null!;

    }
}
