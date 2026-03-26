using ExaminationSystem_API.Dto.QuestionDTO;
using ExaminationSystem_API.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class QuestionController : ControllerBase
    {
        private readonly IQuestionService _questionService;
        public QuestionController(IQuestionService questionService)
        {
            _questionService = questionService;   
        }
        [HttpPost("Add-TF-Question")]
        public async Task<IActionResult> AddTFQuestion([FromBody]TfQuestionDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _questionService.AddTfQuestionAsync(dto , instructorId);
                return Ok("Question Added Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }

        }
        [HttpPost("Add-Mcq-Question")]
        public async Task<IActionResult> AddMcqQuestion([FromBody]McqQuestionDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _questionService.AddMCQQuestionAsync(dto , instructorId);
                return Ok("Question Added Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }

        }
        [HttpPost("Add-text-Question")]
        public async Task<IActionResult> AddTextQuestion([FromBody]TextQuestionDTO dto)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _questionService.AddTextQuestionAsync(dto , instructorId);
                return Ok("Question Added Successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }

        }
        [HttpDelete("Delete-Question/{questionId}")]
        public async Task<IActionResult> DeleteQuestion([FromRoute] int questionId)
        {
            var instructorId = GetInstructorId();
            try
            {
                await _questionService.DeleteQuestionAsync(questionId, instructorId);
                return Ok("Question Deleted Successfully.");
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
