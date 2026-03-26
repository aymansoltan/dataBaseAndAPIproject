namespace ExaminationSystem_API.Models.QueryResults
{
    public class UserLoginResult
    {
        public int UserId { get; set; }

        public string UserName { get; set; }

        public string Email { get; set; }

        public string UserPassword { get; set; } 

        public string Role { get; set; }

        public int? InstructorId { get; set; }

        public int? StudentId { get; set; }
    }
}
