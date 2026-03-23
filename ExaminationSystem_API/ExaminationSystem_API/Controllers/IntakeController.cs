

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
                return this.SuccessResponse("intake added successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
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
                return this.SuccessResponse("intake Updated successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpDelete("Delete-Intake/{id}")]
        public async Task<IActionResult> DeleteIntakeAsync([FromRoute] byte id)
        {
         
            try
            {
                await _intakeService.DeleteIntakeAsync(id) ;
                return this.SuccessResponse("intake deleted successfully.");
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);
            }
        }
        [HttpGet("All-Intacke")]
        public async Task<IActionResult> GetAllIntackeAsync([FromQuery] string? searchTerm, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _intakeService.GetAllIntackeAsync(searchTerm, pageNumber, pageSize);
                return this.SuccessResponse(" all intake get successfully", result);
            }
            catch (Exception ex)
            {
                return this.HandleException(ex);

            }
        }
    }
}
