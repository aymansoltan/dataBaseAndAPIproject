namespace ExaminationSystem_API.Dto.IntakeDTO
{
    public class IntakeReadAllDTO
    {
        public byte IntakeId { get; set; }

        public string IntakeName { get; set; } = null!;

        public bool IsActive { get; set; }

        public DateOnly CreatedAt { get; set; }
    }
}
