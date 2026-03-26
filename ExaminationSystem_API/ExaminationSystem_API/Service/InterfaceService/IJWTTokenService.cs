using ExaminationSystem_API.Models.QueryResults;

namespace ExaminationSystem_API.Service.InterfaceService
{
    public interface IJWTTokenService
    {
        string GrnrateJWTToken(UserLoginResult loginResult);
    }
}
