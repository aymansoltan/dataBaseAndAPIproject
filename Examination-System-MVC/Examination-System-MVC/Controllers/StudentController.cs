using Examination_System_MVC.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;


namespace Examination_System_MVC.Controllers
{
    public class StudentController : Controller
    {
        private readonly ExaminationContext _context;

        public StudentController(ExaminationContext context)
        {
            _context = context;
        }

     
        public async Task<IActionResult> Index()
        {
            var student =await _context.VStudentComprehensiveProfiles.ToListAsync();
            return View(student);
        }
    }
}
