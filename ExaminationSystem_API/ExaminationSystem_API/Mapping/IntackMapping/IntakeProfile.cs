
namespace ExaminationSystem_API.Mapping.IntackMapping
{
    public class IntakeProfile : Profile
    {
        public IntakeProfile()
        {
            CreateMap<Intake, IntakeReadAllDTO>();
        }
    }
}
