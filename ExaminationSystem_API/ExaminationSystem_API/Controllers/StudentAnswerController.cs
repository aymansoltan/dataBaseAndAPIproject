using ExaminationSystem_API.Dto.StudentAnswerDTO;
using ExaminationSystem_API.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StudentAnswerController : ControllerBase
    {
        private readonly IStudentAnswerService _studentAnswerService;
        public StudentAnswerController(IStudentAnswerService studentAnswerService)
        {
             _studentAnswerService = studentAnswerService;
        }
        [HttpPost("Submit-Answer")]
        public async Task<IActionResult> SubmitAnswerAsync([FromBody] SubmitExamDTO dto)
        {
            var studentId = GetStudentId();
            try
            {
                await _studentAnswerService.StudentSubmitAnswerAsync(dto, studentId);
                return Ok("answer submit Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }

        private int GetStudentId()
        {
            var claim = User.FindFirst("StudentId");
            if (claim == null) throw new UnauthorizedAccessException("Instructor ID not found in token.");
            return int.Parse(claim.Value);
        }
    }
}
