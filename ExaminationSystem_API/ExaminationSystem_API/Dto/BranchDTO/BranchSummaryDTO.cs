namespace ExaminationSystem_API.Dto.BranchDTO
{
    public class BranchSummaryDTO
    {
        public string? BranchName { get; set; }

        public string Status { get; set; } = null!;

        public DateOnly? CreationTime { get; set; }
    }
}
