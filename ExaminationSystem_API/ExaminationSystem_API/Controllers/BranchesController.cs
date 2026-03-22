using ExaminationSystem_API.Dto.BranchDTO;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace ExaminationSystem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BranchesController : ControllerBase
    {
        private readonly IBranchService _branchService;
        public BranchesController(IBranchService branchService)
        {
            _branchService = branchService;
        }
        [HttpGet("branches-lookup")]
        public async Task<IActionResult> GetBranches()
        {
            var Branches = await _branchService.GetBranchesLookupAsync();
            return Ok(Branches);
        }
        [HttpPost("Add-Branch")]
        public async Task<IActionResult> AddBranch([FromBody] AddBranchDTO branchDTO)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _branchService.AddBranchAsync(branchDTO);
                return Ok(new
                {
                    success = true,
                    message = "Branch added successfully using Stored Procedure."
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "An error occurred while adding the branch.",
                    detail = ex.Message
                });
            }
        }
        [HttpPut("Update-Branch/{id}")]
        public async Task<IActionResult> UpdateBranch(byte id, [FromBody] UpdateBranchDTO updateBranch)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            try
            {
                await _branchService.UpdateBranchAsync(id, updateBranch);
                return Ok(new
                {
                    success = true,
                    message = "Branch updated successfully using Stored Procedure."
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
        [HttpPut("Activate-Branch/{id}")]
        public async Task<IActionResult> ActivateBranch(byte id)
        {
            try
            {
                await _branchService.ActivateBranchAsync(id);
                return Ok(new
                {
                    success = true,
                    message = "Branch Activate successfully using Stored Procedure."
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
        [HttpDelete("Delete-Branch/{id}")]
        public async Task<IActionResult> DeleteBranch(byte id)
        {

            try
            {
                await _branchService.DeleteBranchAsync(id);
                return Ok(new
                {
                    success = true,
                    message = "Branch deleted successfully using Stored Procedure (Deleted or Deactivated via Trigger)."
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
        [HttpGet("GetAll-Branches")]

        public async Task<IActionResult> GetBranchesSummary([FromQuery] string? searchTerm, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var result = await _branchService.GetAllBranchSummryAsync(searchTerm, pageNumber, pageSize);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
