namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class intakeRepository : GenericRepository<Intake>, IIntakeRepository
    {
        private readonly ExaminationContext _context;
        public intakeRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddIntakeWithStoredAsync(AddIntakeDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = {dto.IntakeName} ");
        public async Task UpdateIntakeWithStoredAsync(UpdateIntakeDTO dto) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateIntake @IntakeId = {dto.IntakeID} , @IntakeName = {dto.IntakeName} ");
        public async Task DeleteIntakeWithStoredAsync(byte intakeId) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_DeleteIntake @IntakeId = {intakeId} ");

    }
}
