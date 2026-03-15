using System.ComponentModel.DataAnnotations;

namespace Examination_System_MVC.ViewModel.BranchVM
{
    public class AddBranchVM
    {
        [Required(ErrorMessage ="the branch name is required")]
        [StringLength(15 , MinimumLength =3 ,ErrorMessage ="branch name must be between 3 and 15 letters")]
        [Display(Name ="branch name")]
        public string BranchName { get; set; } = null!;

    }
}
