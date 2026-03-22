namespace ExaminationSystem_API.Dto.TrackDTO
{
    public class TrackReadAllDTO
    {
        public short TrackId { get; set; }
        public string TrackName { get; set; } = null!;
        public string DepartmentName { get; set; } = null!;
        public bool IsActive { get; set; }
        public string BranchName { get; set; }

    }
}
