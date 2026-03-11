using System;
using System.Collections.Generic;

namespace Examination_System_MVC.Models;

public partial class QuestionOption
{
    public short QuestionOptionId { get; set; }

    public string QuestionOptionText { get; set; } = null!;

    public short QuestionId { get; set; }

    public virtual Question Question { get; set; } = null!;
}
