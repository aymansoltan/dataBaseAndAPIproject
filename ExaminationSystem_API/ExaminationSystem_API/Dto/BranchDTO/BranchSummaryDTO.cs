namespace ExaminationSystem_API.Dto.BranchDTO
{
    public class BranchSummaryDTO
    {
        public byte BranchId { get; set; }

        public string? BranchName { get; set; }

        public string Status { get; set; } = null!;

        public DateOnly? CreationTime { get; set; }
    }
}
