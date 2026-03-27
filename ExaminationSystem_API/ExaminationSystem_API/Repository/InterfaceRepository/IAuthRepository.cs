using ExaminationSystem_API.QueryResults;

namespace ExaminationSystem_API.Repository.InterfaceRepository
{
    public interface IAuthRepository :IGenericRepository<UserAccount>
    {
        Task AddUserWithStoredAsync(RegisterBaseDTO dto);
        Task UpdateUserWithStoredAsync(BaseUpdateMemberDTO dto);
        Task DeleteUserWithStoredAsync(int UserId);
        Task<UserLoginResult?> GetUserByEmailAsync(string email);
    }
}
