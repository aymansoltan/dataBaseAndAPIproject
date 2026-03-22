namespace ExaminationSystem_API.Repository.ClassRepository
{
    public class intakeRepository : GenericRepository<Intake>, IIntakeRepository
    {
        private readonly ExaminationContext _context;
        public intakeRepository(ExaminationContext context) : base(context)
        {
            _context = context;
        }
        public async Task AddIntakeWithStoredAsync(string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_AddIntake @IntakeName = {name} ");
        public async Task UpdateIntakeWithStoredAsync( byte intakeId,string name) => await _context.Database.ExecuteSqlInterpolatedAsync($"EXEC [TrainingMangerStp].stp_UpdateIntake @IntakeId = {intakeId} , @IntakeName = {name} ");

    }
}
