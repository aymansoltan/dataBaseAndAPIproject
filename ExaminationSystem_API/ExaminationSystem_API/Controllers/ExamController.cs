using ExaminationSystem_API.Dto.ExamDto;
using ExaminationSystem_API.Dto.GradingDTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExamController : ControllerBase
    {
        private readonly IExamService _examService;
        public ExamController(IExamService examService)
        {
            _examService = examService;
        }
        [HttpPost("Add-Random-Exam")]
        public async Task<IActionResult> AddRandomExamAsync([FromBody] RandomExamDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _examService.AddRandomExamAsync(dto, instructorId);
                return Ok("Exam Added Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpPost("Add-Manaul-Exam")]
        public async Task<IActionResult> AddManaulExamAsync([FromBody] ManualExamDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _examService.AddManaulExamAsync(dto, instructorId);
                return Ok("Exam Added Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpPost("Grade-Text-Questions")]
        [Authorize(Roles = "Instructor")]
        public async Task<IActionResult> GradeTextQuestions([FromBody] InstructorGradingDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _examService.GradingAsync(dto, instructorId);
                return Ok("Grading completed and results finalized.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }

        [HttpDelete("Delete-Exam/{examId}")]
        public async Task<IActionResult> DeleteQuestion([FromRoute] short examId)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _examService.DeleteExamAsync(examId, instructorId);
                return Ok("Exam Deleted Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }

        }
        private int GetInstructorId()
        {
            var claim = User.FindFirst("InstructorId");
            if (claim == null) throw new UnauthorizedAccessException("Instructor ID not found in token.");
            return int.Parse(claim.Value);
        }
    }

}
