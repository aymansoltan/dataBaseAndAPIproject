using ExaminationSystem_API.Dto.IntakeDTO;
using System.Threading.Tasks;

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
    }
}
