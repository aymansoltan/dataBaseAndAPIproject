

using ExaminationSystem_API.Dto.AuthDTO;
//using ExaminationSystem_API.Models.QueryResults;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Service.ClassService
{
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IJWTTokenService _tokenService;
        public AuthService(IUnitOfWork unitOfWork, IJWTTokenService tokenService)
        {
            _unitOfWork = unitOfWork;
            _tokenService = tokenService;
        }
        public async Task RegisterStudentAsync(RegisterStudentDTO studentDTO)
        {
            studentDTO.TargetType = TargetType.std;
            studentDTO.Password = BCrypt.Net.BCrypt.HashPassword(studentDTO.Password);
            await _unitOfWork.Auths.AddUserWithStoredAsync(studentDTO);
        }
        public async Task RegisterInstructorAsync(RegisterInstructorDTO instructorDTO)
        {
            instructorDTO.TargetType = TargetType.ins;
            instructorDTO.Password = BCrypt.Net.BCrypt.HashPassword(instructorDTO.Password);

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
        public async Task<string> LoginAsync(LoginDto dto)
        {
            var userResult = await _unitOfWork.Auths.GetUserByEmailAsync(dto.Email);
            if (userResult == null)
                throw new Exception("email or password is not valid");
            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.Password, userResult.UserPassword);
            if (!isPasswordValid)
                throw new Exception("email or password is not valid");
            var token = _tokenService.GrnrateJWTToken(userResult);

            return token;

        }

        public async Task<IEnumerable<InstructoreLookupDTO>> GetInstructoreLookupAsync()
        {
            return await _unitOfWork.Instructors
                .GetAllQueryable()
                .Where(i => i.IsActive == true && i.IsDeleted == false)
                .Select(i => new InstructoreLookupDTO
                {
                    instructorId = i.InstructorId,
                    instructorName = i.FirstName + " " + i.LastName
                })
                .ToListAsync();
        }

    }
}
