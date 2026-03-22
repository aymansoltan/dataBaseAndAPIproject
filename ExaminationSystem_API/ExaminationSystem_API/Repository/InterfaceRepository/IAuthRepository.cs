using ExaminationSystem_API.Dto.AuthDTO;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IAuthRepository :IGenericRepository<UserAccount>
    {
        Task AddUserWithStoredAsync(RegisterBaseDTO dto);
        Task UpdateUserWithStoredAsync(BaseUpdateMemberDTO dto);
        Task DeleteUserWithStoredAsync(int UserId);
    }
}
