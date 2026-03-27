using ExaminationSystem_API.QueryResults;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace ExaminationSystem_API.Service.ClassService
{
    public class JWTTokenService : IJWTTokenService
    {
        private readonly IConfiguration _config;
        public JWTTokenService(IConfiguration configuration)
        {
            _config = configuration;
        }
        public string GrnrateJWTToken(UserLoginResult loginResult)
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier , loginResult.UserId.ToString()),
                new Claim(ClaimTypes.Name , loginResult.UserName),
                new Claim(ClaimTypes.Email , loginResult.Email),
                new Claim(ClaimTypes.Role , loginResult.Role)
            };
            if (loginResult.InstructorId.HasValue)
                claims.Add(new Claim("InstructorId", loginResult.InstructorId.Value.ToString()));

            if (loginResult.StudentId.HasValue)
                claims.Add(new Claim("StudentId", loginResult.StudentId.Value.ToString()));
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddHours(3),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
