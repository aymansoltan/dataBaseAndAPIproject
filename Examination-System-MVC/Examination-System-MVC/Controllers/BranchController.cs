global using Microsoft.AspNetCore.Mvc;

namespace Examination_System_MVC.Controllers
{
    public class BranchController : Controller
    {
        private readonly IBranchService _branchService;
        public BranchController(IBranchService branchService)
        {
            _branchService = branchService;
        }

        [HttpPost]
        public async Task<IActionResult> Create(AddBranchVM model)
        {
            if (!ModelState.IsValid) return View(model);
            try
            {
                await _branchService.AddBranchAsync(model);
                TempData["SuccessMessage"] ="branch Added Successfully";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = ex.Message;
                return View(model);
            } 
        }
    }
}
