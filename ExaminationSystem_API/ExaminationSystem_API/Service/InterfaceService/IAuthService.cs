
namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IAuthService
    {
        Task RegisterStudentAsync(RegisterStudentDTO studentDTO);
        Task RegisterInstructorAsync(RegisterInstructorDTO instructorDTO);
        Task UpdateAccountStudentAsync(UpdateStudentDTO studentDTO);
        Task UpdateAccountInstructorAsync(UpdateInstructorDTO instructorDTO);
        Task DeleteAccountAsync(int id);
        Task<string> LoginAsync(LoginDto dto);
    }
}
