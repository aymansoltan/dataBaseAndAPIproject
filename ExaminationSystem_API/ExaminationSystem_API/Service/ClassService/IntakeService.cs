

namespace ExaminationSystem_API.Service.ClassService
{
    public class IntakeService :IIntakeService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public IntakeService(IUnitOfWork unitOfWork , IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task AddIntakeAsync(AddIntakeDTO intakeDTO)
        {
            await _unitOfWork.Intakes.AddIntakeWithStoredAsync(intakeDTO.IntakeName);
        }
        public async Task UpdateIntakeAsync(UpdateIntakeDTO intakeDTO)
        {
            await _unitOfWork.Intakes.UpdateIntakeWithStoredAsync(intakeDTO.IntakeID,intakeDTO.IntakeName);
        }
        public async Task DeleteIntakeAsync(byte id)
        {
            await _unitOfWork.Intakes.DeleteIntakeWithStoredAsync(id);
        }

        public async Task<PaginatedList<IntakeReadAllDTO>> GetAllIntackeAsync(string? searchTerm, int pageNumber, int pageSize)
        {
            IQueryable<Intake> query = _unitOfWork.Intakes.GetAllQueryable()
                .AsNoTracking()
                .Where(i => i.IsDeleted==false);
              
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                searchTerm = searchTerm.Trim().ToLower();
                query = query.Where(t => t.IntakeName.ToLower().Contains(searchTerm));
            }
            return await query.ToPaginatedListAsync<Intake, IntakeReadAllDTO>(_mapper, pageNumber, pageSize);
        }

    }
}
