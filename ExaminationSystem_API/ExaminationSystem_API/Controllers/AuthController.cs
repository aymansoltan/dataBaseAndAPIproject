using ExaminationSystem_API.Dto.AuthDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register-student")]
        public async Task<IActionResult> RegisterStudent([FromBody]RegisterStudentDTO dto)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _authService.RegisterStudentAsync(dto);
                return Ok(new { message = "Student registered successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });

            }

        }
        [HttpPost("register-instructor")]
        public async Task<IActionResult> RegisterInstructor([FromBody] RegisterInstructorDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                await _authService.RegisterInstructorAsync(dto);
                return Ok(new { message = "Instructor registered successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });

            }

        }

        [HttpPut("Update-Account-instructor/{id}")]
        public async Task<IActionResult> UpdateAccountInstructorAsync([FromRoute]int id , [FromBody]UpdateInstructorDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if(dto.UserId !=id)
                return BadRequest(new { success = false, message = "ID mismatch." });

            try
            {
                await _authService.UpdateAccountInstructorAsync(dto);
                return Ok(new { message = "Instructor Updated account successfully" });
            }
            catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });

            }

        }


        [HttpPut("Update-Account-Student/{int id}")]
        public async Task<IActionResult> UpdateAccountStudentAsync([FromRoute]int id,[FromBody]UpdateStudentDTO dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (dto.UserId !=id)
                return BadRequest(new { success = false, message = "ID mismatch." });
            try
            {
                await _authService.UpdateAccountStudentAsync(dto);
                return Ok(new { message = "Student Updated account successfully" });
            }
            catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });

            }

        }
        [HttpDelete("Delete-Account/{id}")]
        public async Task<IActionResult> DeleteAccountAsync([FromRoute]int id)
        {

            try
            {
                await _authService.DeleteAccountAsync(id);
                return Ok(new { message = " Deleted account successfully" });
            }
            catch(Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });

            }

        }
       
    }
}
