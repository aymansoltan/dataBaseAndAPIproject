using ExaminationSystem_API.Dto.IntakeDTO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IntakeController : ControllerBase
    {
        private readonly IIntakeService _intakeService;
        public IntakeController(IIntakeService intakeService)
        {
            _intakeService = intakeService;
        }

        [HttpPost("Add-Intake")]
        public async Task<IActionResult> AddIntakeAsync([FromBody]AddIntakeDTO intakeDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                await _intakeService.AddIntakeAsync(intakeDTO) ;
                return Ok(new { success = true, message = "intake added successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
        [HttpPut("Update-Intake/{id}")]
        public async Task<IActionResult> UpdateIntakeAsync([FromRoute] byte id,[FromBody]UpdateIntakeDTO intakeDTO)
        {
            if(!ModelState.IsValid) return BadRequest(ModelState);
            if (id != intakeDTO.IntakeID)
                return BadRequest(new { success = false, message = "ID mismatch." });
            try
            {
                await _intakeService.UpdateIntakeAsync(intakeDTO) ;
                return Ok(new { success = true, message = "intake Updated successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
