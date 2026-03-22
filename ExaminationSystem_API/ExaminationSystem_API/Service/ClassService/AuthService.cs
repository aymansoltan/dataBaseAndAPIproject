using ExaminationSystem_API.Dto.AuthDTO;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class AuthService :IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        public AuthService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task RegisterStudentAsync(RegisterStudentDTO studentDTO)
        {
            studentDTO.TargetType = TargetType.std;
            await _unitOfWork.Auths.AddUserWithStoredAsync(studentDTO);
        }
        public async Task RegisterInstructorAsync(RegisterInstructorDTO instructorDTO )
        {
            instructorDTO.TargetType = TargetType.ins;
            await _unitOfWork.Auths.AddUserWithStoredAsync(instructorDTO);
        }

        public async Task UpdateAccountStudentAsync(UpdateStudentDTO studentDTO)
        {
            await _unitOfWork.Auths.UpdateUserWithStoredAsync(studentDTO);
        }
        public async Task UpdateAccountInstructorAsync(UpdateInstructorDTO instructorDTO)
        {
            await _unitOfWork.Auths.UpdateUserWithStoredAsync(instructorDTO);
        }

        public async Task DeleteAccountAsync(int id)
        {
            await _unitOfWork.Auths.DeleteUserWithStoredAsync(id);
        }
    }
}
