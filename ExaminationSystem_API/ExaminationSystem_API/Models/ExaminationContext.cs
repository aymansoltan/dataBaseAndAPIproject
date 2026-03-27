using System;
using System.Collections.Generic;
using ExaminationSystem_API.QueryResults;
using Microsoft.EntityFrameworkCore;

namespace ExaminationSystem_API.Models;

public partial class ExaminationContext : DbContext
{
    public ExaminationContext()
    {
    }

    public ExaminationContext(DbContextOptions<ExaminationContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Branch> Branches { get; set; }

    public virtual DbSet<Course> Courses { get; set; }

    public virtual DbSet<CourseInstance> CourseInstances { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Exam> Exams { get; set; }

    public virtual DbSet<Instructor> Instructors { get; set; }

    public virtual DbSet<Intake> Intakes { get; set; }

    public virtual DbSet<IntakeTrack> IntakeTracks { get; set; }

    public virtual DbSet<Question> Questions { get; set; }

    public virtual DbSet<QuestionOption> QuestionOptions { get; set; }

    public virtual DbSet<Student> Students { get; set; }

    public virtual DbSet<StudentAnswer> StudentAnswers { get; set; }

    public virtual DbSet<StudentExamResult> StudentExamResults { get; set; }

    public virtual DbSet<Track> Tracks { get; set; }

    public virtual DbSet<UserAccount> UserAccounts { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<VActiveIntakeMap> VActiveIntakeMaps { get; set; }

    public virtual DbSet<VBranchsummary> VBranchsummaries { get; set; }

    public virtual DbSet<VDepartmentBranchSummary> VDepartmentBranchSummaries { get; set; }

    public virtual DbSet<VExamsComprehensiveDetail> VExamsComprehensiveDetails { get; set; }

    public virtual DbSet<VInstructorProfile> VInstructorProfiles { get; set; }

    public virtual DbSet<VIntakeGrowth> VIntakeGrowths { get; set; }

    public virtual DbSet<VOrgIntegrityCheck> VOrgIntegrityChecks { get; set; }

    public virtual DbSet<VOrgnizationSummarySchema> VOrgnizationSummarySchemas { get; set; }

    public virtual DbSet<VQuestionBankSummary> VQuestionBankSummaries { get; set; }

    public virtual DbSet<VStudentComprehensiveProfile> VStudentComprehensiveProfiles { get; set; }

    public virtual DbSet<VStudentCoursesInstructor> VStudentCoursesInstructors { get; set; }

    public virtual DbSet<VStudentsFinalResult> VStudentsFinalResults { get; set; }

    public virtual DbSet<VTrackDepartmentBranchDetail> VTrackDepartmentBranchDetails { get; set; }

    public virtual DbSet<VTrackIntakeDetail> VTrackIntakeDetails { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=.;Database=ExaminationSystemDB;Trusted_Connection=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Branch>(entity =>
        {
            entity.HasKey(e => e.BranchId).HasName("BranchPK");

            entity.ToTable("Branch", "orgnization", tb =>
                {
                    tb.HasTrigger("trg_SoftDeleteBranch");
                    tb.HasTrigger("trg_inactivateDepartmentWhenInActiveBranch");
                });

            entity.HasIndex(e => e.BranchName, "BranchNameUniqe").IsUnique();

            entity.Property(e => e.BranchId).ValueGeneratedOnAdd();
            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
        });

        modelBuilder.Entity<Course>(entity =>
        {
            entity.HasKey(e => e.CourseId).HasName("CoursePK");

            entity.ToTable("Course", "Courses", tb => tb.HasTrigger("trg_Softcoursedelete"));

            entity.HasIndex(e => e.CourseName, "CourseNameUnique").IsUnique();

            entity.Property(e => e.CourseDescription)
                .HasMaxLength(500)
                .IsUnicode(false);
            entity.Property(e => e.CourseName)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.MaxDegree).HasDefaultValue(100);
            entity.Property(e => e.MinDegree).HasDefaultValue(50);
        });

        modelBuilder.Entity<CourseInstance>(entity =>
        {
            entity.HasKey(e => e.CourseInstanceId).HasName("CourseInstancePK");

            entity.ToTable("CourseInstance", "Courses", tb => tb.HasTrigger("trg_preventdeleteinstance"));

            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");

            entity.HasOne(d => d.Branch).WithMany(p => p.CourseInstances)
                .HasForeignKey(d => d.BranchId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("CI_BranchFK");

            entity.HasOne(d => d.Course).WithMany(p => p.CourseInstances)
                .HasForeignKey(d => d.CourseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("CI_CourseFK");

            entity.HasOne(d => d.Instructor).WithMany(p => p.CourseInstances)
                .HasForeignKey(d => d.InstructorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("CI_InstructorFK");

            entity.HasOne(d => d.Intake).WithMany(p => p.CourseInstances)
                .HasForeignKey(d => d.IntakeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("CI_IntakeFK");

            entity.HasOne(d => d.Track).WithMany(p => p.CourseInstances)
                .HasForeignKey(d => d.TrackId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("CI_TrackFK");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.HasKey(e => e.DeptId).HasName("DepartmentPK");

            entity.ToTable("Department", "orgnization", tb =>
                {
                    tb.HasTrigger("trg_CheckBranchStatusBeforeInsert");
                    tb.HasTrigger("trg_SoftDeleteDepartment");
                    tb.HasTrigger("trg_inactivateTracksWhenInActiveDerpartment");
                });

            entity.HasIndex(e => new { e.DeptName, e.BranchId }, "DepartmentName_branchUniqe").IsUnique();

            entity.Property(e => e.DeptId).ValueGeneratedOnAdd();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.DeptName)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");

            entity.HasOne(d => d.Branch).WithMany(p => p.Departments)
                .HasForeignKey(d => d.BranchId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("DepartmentBranchFK");
        });

        modelBuilder.Entity<Exam>(entity =>
        {
            entity.HasKey(e => e.ExamId).HasName("ExamPK");

            entity.ToTable("Exam", "exams", tb => tb.HasTrigger("trg_softdeleteexam"));

            entity.Property(e => e.DurationMinutes).HasComputedColumnSql("(datediff(minute,[StartTime],[EndTime]))", true);
            entity.Property(e => e.EndTime).HasPrecision(0);
            entity.Property(e => e.ExamTitle)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.ExamType)
                .HasMaxLength(11)
                .IsUnicode(false)
                .HasDefaultValue("Regular");
            entity.Property(e => e.IsDeleted).HasDefaultValue(false);
            entity.Property(e => e.StartTime).HasPrecision(0);

            entity.HasOne(d => d.Branch).WithMany(p => p.Exams)
                .HasForeignKey(d => d.BranchId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Exam_BranchFK");

            entity.HasOne(d => d.CourseInstance).WithMany(p => p.Exams)
                .HasForeignKey(d => d.CourseInstanceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Exam_CourseInstanceFK");

            entity.HasOne(d => d.Intake).WithMany(p => p.Exams)
                .HasForeignKey(d => d.IntakeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Exam_IntakeFK");

            entity.HasOne(d => d.Track).WithMany(p => p.Exams)
                .HasForeignKey(d => d.TrackId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("Exam_TrackFK");

            entity.HasMany(d => d.Questions).WithMany(p => p.Exams)
                .UsingEntity<Dictionary<string, object>>(
                    "ExamQuestion",
                    r => r.HasOne<Question>().WithMany()
                        .HasForeignKey("QuestionId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("EQ_QuestionFK"),
                    l => l.HasOne<Exam>().WithMany()
                        .HasForeignKey("ExamId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("EQ_ExamFK"),
                    j =>
                    {
                        j.HasKey("ExamId", "QuestionId").HasName("ExamQuestionPK");
                        j.ToTable("ExamQuestion", "exams", tb => tb.HasTrigger("trg_UpdateExamTotalDegree"));
                    });
        });

        modelBuilder.Entity<Instructor>(entity =>
        {
            entity.HasKey(e => e.InstructorId).HasName("InstructorPK");

            entity.ToTable("Instructor", "userAcc");

            entity.HasIndex(e => e.NationalId, "InstructorNationalIDUnique").IsUnique();

            entity.HasIndex(e => e.Phone, "InstructorPhoneUnique").IsUnique();

            entity.HasIndex(e => e.UserId, "InstructorUserUnique").IsUnique();

            entity.Property(e => e.Age).HasComputedColumnSql("(datediff(year,[BirthDate],getdate()))", false);
            entity.Property(e => e.FirstName)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.HireDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.InsAddress)
                .HasMaxLength(150)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.LastName)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.NationalId)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NationalID");
            entity.Property(e => e.Phone)
                .HasMaxLength(11)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.Salary).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Specialization)
                .HasMaxLength(50)
                .IsUnicode(false);

            entity.HasOne(d => d.Dept).WithMany(p => p.Instructors)
                .HasForeignKey(d => d.DeptId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("InstructorDeptFK");

            entity.HasOne(d => d.User).WithOne(p => p.Instructor)
                .HasForeignKey<Instructor>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("InstructorUserFK");
        });

        modelBuilder.Entity<Intake>(entity =>
        {
            entity.HasKey(e => e.IntakeId).HasName("IntakePK");

            entity.ToTable("Intake", "orgnization", tb =>
                {
                    tb.HasTrigger("trg_SoftDeleteIntake");
                    tb.HasTrigger("trg_syncIntakeTrackStatus");
                });

            entity.HasIndex(e => e.IntakeName, "IntakeNameUniqe").IsUnique();

            entity.Property(e => e.IntakeId).ValueGeneratedOnAdd();
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
        });

        modelBuilder.Entity<IntakeTrack>(entity =>
        {
            entity.HasKey(e => new { e.IntakeId, e.TrackId }).HasName("IntakeTrackPK");

            entity.ToTable("IntakeTrack", "orgnization");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");

            entity.HasOne(d => d.Intake).WithMany(p => p.IntakeTracks)
                .HasForeignKey(d => d.IntakeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("IT_IntackFK");

            entity.HasOne(d => d.Track).WithMany(p => p.IntakeTracks)
                .HasForeignKey(d => d.TrackId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("IT_TrackFK");
        });
        modelBuilder.Entity<UserLoginResult>().HasNoKey();
        modelBuilder.Entity<Question>(entity =>
        {
            entity.HasKey(e => e.QuestionId).HasName("QuestionPK");

            entity.ToTable("Question", "exams", tb => tb.HasTrigger("trg_softdeletequestion"));

            entity.Property(e => e.BestAnswer)
                .HasMaxLength(1000)
                .IsUnicode(false);
            entity.Property(e => e.CorrectAnswer)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.Points).HasDefaultValue((byte)1);
            entity.Property(e => e.QuestionText)
                .HasMaxLength(700)
                .IsUnicode(false);
            entity.Property(e => e.QuestionType)
                .HasMaxLength(5)
                .IsUnicode(false);

            entity.HasOne(d => d.Course).WithMany(p => p.Questions)
                .HasForeignKey(d => d.CourseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Question_Course");
        });

        modelBuilder.Entity<QuestionOption>(entity =>
        {
            entity.HasKey(e => e.QuestionOptionId).HasName("QuestionOptionPK");

            entity.ToTable("QuestionOption", "exams");

            entity.Property(e => e.QuestionOptionText)
                .HasMaxLength(500)
                .IsUnicode(false);

            entity.HasOne(d => d.Question).WithMany(p => p.QuestionOptions)
                .HasForeignKey(d => d.QuestionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("OQ_QuestionFK");
        });

        modelBuilder.Entity<Student>(entity =>
        {
            entity.HasKey(e => e.StudentId).HasName("StudentPK");

            entity.ToTable("Student", "userAcc");

            entity.HasIndex(e => e.NationalId, "StudentNationalIDUnique").IsUnique();

            entity.HasIndex(e => e.Phone, "StudentPhoneUnique").IsUnique();

            entity.HasIndex(e => e.UserId, "StudentUserUnique").IsUnique();

            entity.Property(e => e.Age).HasComputedColumnSql("(datediff(year,[BirthDate],getdate()))", false);
            entity.Property(e => e.FirstName)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.Gender)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.LastName)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.NationalId)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("NationalID");
            entity.Property(e => e.Phone)
                .HasMaxLength(11)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.StuAddress)
                .HasMaxLength(150)
                .IsUnicode(false);

            entity.HasOne(d => d.Branch).WithMany(p => p.Students)
                .HasForeignKey(d => d.BranchId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StudentBranchFK");

            entity.HasOne(d => d.Intake).WithMany(p => p.Students)
                .HasForeignKey(d => d.IntakeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StudentIntakeFK");

            entity.HasOne(d => d.Track).WithMany(p => p.Students)
                .HasForeignKey(d => d.TrackId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StudentTrackFK");

            entity.HasOne(d => d.User).WithOne(p => p.Student)
                .HasForeignKey<Student>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("StudentUserFK");
        });

        modelBuilder.Entity<StudentAnswer>(entity =>
        {
            entity.HasKey(e => new { e.StudentId, e.ExamId, e.QuestionId }).HasName("StudentAnswerPK");

            entity.ToTable("Student_Answer", "exams", tb => tb.HasTrigger("trg_studentanswer"));

            entity.Property(e => e.StudentResponse).IsUnicode(false);
            entity.Property(e => e.SystemGrade).HasDefaultValue((byte)0);

            entity.HasOne(d => d.Exam).WithMany(p => p.StudentAnswers)
                .HasForeignKey(d => d.ExamId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ans_Exam");

            entity.HasOne(d => d.Question).WithMany(p => p.StudentAnswers)
                .HasForeignKey(d => d.QuestionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ans_Question");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentAnswers)
                .HasForeignKey(d => d.StudentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ans_Student");
        });

        modelBuilder.Entity<StudentExamResult>(entity =>
        {
            entity.HasKey(e => new { e.StudentId, e.ExamId }).HasName("StudentResultPK");

            entity.ToTable("Student_Exam_Result", "exams");

            entity.Property(e => e.IsPassed).HasDefaultValue(false);

            entity.HasOne(d => d.Exam).WithMany(p => p.StudentExamResults)
                .HasForeignKey(d => d.ExamId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Res_Exam");

            entity.HasOne(d => d.Student).WithMany(p => p.StudentExamResults)
                .HasForeignKey(d => d.StudentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Res_Student");
        });

        modelBuilder.Entity<Track>(entity =>
        {
            entity.HasKey(e => e.TrackId).HasName("TrackPK");

            entity.ToTable("Track", "orgnization", tb =>
                {
                    tb.HasTrigger("trg_SoftDeleteTrack");
                    tb.HasTrigger("trg_intakeTrackinactivateWhenInaactiveTrack");
                });

            entity.HasIndex(e => new { e.TrackName, e.DeprtmentId }, "TrackName_DeptUniqe").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false);

            entity.HasOne(d => d.Deprtment).WithMany(p => p.Tracks)
                .HasForeignKey(d => d.DeprtmentId)
                .HasConstraintName("TrackDepartmentFK");
        });

        modelBuilder.Entity<UserAccount>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("UserPK");

            entity.ToTable("UserAccount", "userAcc", tb => tb.HasTrigger("trg_SoftDeleteUserAccount"));

            entity.HasIndex(e => e.Email, "EmailUnique").IsUnique();

            entity.HasIndex(e => e.UserName, "UserNameUnique").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("createdAt");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("isActive");
            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName("isDeleted");
            entity.Property(e => e.UserName)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.UserPassword).HasMaxLength(250);

            entity.HasOne(d => d.Role).WithMany(p => p.UserAccounts)
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("UserRoleFK");
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("RolePK");

            entity.ToTable("UserRole", "userAcc", tb => tb.HasTrigger("trg_PreventModifyUserRole"));

            entity.HasIndex(e => e.RoleName, "RoleNameUniqe").IsUnique();

            entity.Property(e => e.RoleId).ValueGeneratedOnAdd();
            entity.Property(e => e.RoleName)
                .HasMaxLength(20)
                .IsUnicode(false);
        });

        modelBuilder.Entity<VActiveIntakeMap>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_active_intake_map", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.Department)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("department");
            entity.Property(e => e.IntakeYear)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_year");
            entity.Property(e => e.LinkStatus).HasColumnName("link_status");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
        });

        modelBuilder.Entity<VBranchsummary>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_branchsummary", "MangerViews");

            entity.Property(e => e.BranchId)
                .ValueGeneratedOnAdd()
                .HasColumnName("branch_id");
            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.CreationTime).HasColumnName("creation_time");
            entity.Property(e => e.Status)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("status");
        });

        modelBuilder.Entity<VDepartmentBranchSummary>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_department_branch_summary", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.CreationTime).HasColumnName("creation_time");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("department_name");
            entity.Property(e => e.Status)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("status");
        });

        modelBuilder.Entity<VExamsComprehensiveDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_exams_comprehensive_details", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.CourseName)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("course_name");
            entity.Property(e => e.DurationMin).HasColumnName("duration_min");
            entity.Property(e => e.EndTime)
                .HasPrecision(0)
                .HasColumnName("end_time");
            entity.Property(e => e.ExamStatus)
                .HasMaxLength(8)
                .IsUnicode(false)
                .HasColumnName("exam_status");
            entity.Property(e => e.ExamTitle)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("exam_title");
            entity.Property(e => e.ExamType)
                .HasMaxLength(11)
                .IsUnicode(false)
                .HasColumnName("exam_type");
            entity.Property(e => e.InstructorName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("instructor_name");
            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_name");
            entity.Property(e => e.StartTime)
                .HasPrecision(0)
                .HasColumnName("start_time");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
        });

        modelBuilder.Entity<VInstructorProfile>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_instructor_profiles", "MangerViews");

            entity.Property(e => e.AccountCreatedAt).HasColumnName("account_created_at");
            entity.Property(e => e.AccountStatus)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("account_status");
            entity.Property(e => e.Age).HasColumnName("age");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("department_name");
            entity.Property(e => e.FullName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("full_name");
            entity.Property(e => e.HireDate).HasColumnName("hire_date");
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(11)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("phone_number");
            entity.Property(e => e.RoleName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("role_name");
            entity.Property(e => e.Salary)
                .HasColumnType("decimal(10, 2)")
                .HasColumnName("salary");
            entity.Property(e => e.Specialization)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("specialization");
            entity.Property(e => e.Ssn)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("ssn");
            entity.Property(e => e.UserEmail)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("user_email");
            entity.Property(e => e.UserName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("user_name");
        });

        modelBuilder.Entity<VIntakeGrowth>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_intake_growth", "MangerViews");

            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_name");
            entity.Property(e => e.NumberOfTracks).HasColumnName("number_of_tracks");
            entity.Property(e => e.StartDate).HasColumnName("start_date");
        });

        modelBuilder.Entity<VOrgIntegrityCheck>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_org_integrity_check", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.TotalActiveIntakes).HasColumnName("total_active_intakes");
            entity.Property(e => e.TotalDepartments).HasColumnName("total_departments");
            entity.Property(e => e.TotalTracks).HasColumnName("total_tracks");
        });

        modelBuilder.Entity<VOrgnizationSummarySchema>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_orgnizationSummarySchema", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("department_name");
            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_name");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
            entity.Property(e => e.TrackStatus)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("track_status");
        });

        modelBuilder.Entity<VQuestionBankSummary>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_question_bank_summary", "MangerViews");

            entity.Property(e => e.AveragePoints).HasColumnName("average_points");
            entity.Property(e => e.CourseName)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("course_name");
            entity.Property(e => e.QuestionType)
                .HasMaxLength(5)
                .IsUnicode(false)
                .HasColumnName("question_type");
            entity.Property(e => e.TotalPointsAvailable).HasColumnName("total_points_available");
            entity.Property(e => e.TotalQuestions).HasColumnName("total_questions");
        });

        modelBuilder.Entity<VStudentComprehensiveProfile>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_student_comprehensive_profile", "MangerViews");

            entity.Property(e => e.AccountCreatedAt).HasColumnName("account_created_at");
            entity.Property(e => e.AccountStatus)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("account_status");
            entity.Property(e => e.Age).HasColumnName("age");
            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.FullName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("full_name");
            entity.Property(e => e.Gender)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("gender");
            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_name");
            entity.Property(e => e.PhoneNumber)
                .HasMaxLength(11)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("phone_number");
            entity.Property(e => e.RoleName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("role_name");
            entity.Property(e => e.Ssn)
                .HasMaxLength(14)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("ssn");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
            entity.Property(e => e.UserEmail)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("user_email");
            entity.Property(e => e.UserName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("user_name");
        });

        modelBuilder.Entity<VStudentCoursesInstructor>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_student_courses_instructor", "MangerViews");

            entity.Property(e => e.Academicyear).HasColumnName("academicyear");
            entity.Property(e => e.Branch)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch");
            entity.Property(e => e.CourseName)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("course_name");
            entity.Property(e => e.Coursedescription)
                .HasMaxLength(500)
                .IsUnicode(false)
                .HasColumnName("coursedescription");
            entity.Property(e => e.InstructorName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("instructor_name");
            entity.Property(e => e.Intake)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake");
            entity.Property(e => e.IsCourseActive).HasColumnName("is_course_active");
            entity.Property(e => e.StudentName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("student_name");
            entity.Property(e => e.Track)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track");
        });

        modelBuilder.Entity<VStudentsFinalResult>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_students_final_results", "MangerViews");

            entity.Property(e => e.CourseName)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("course_name");
            entity.Property(e => e.ExamDate).HasColumnName("exam_date");
            entity.Property(e => e.MaxGrade).HasColumnName("max_grade");
            entity.Property(e => e.PassingGrade).HasColumnName("passing_grade");
            entity.Property(e => e.Percentage).HasColumnName("percentage");
            entity.Property(e => e.ResultStatus)
                .HasMaxLength(4)
                .IsUnicode(false)
                .HasColumnName("result_status");
            entity.Property(e => e.StudentName)
                .HasMaxLength(41)
                .IsUnicode(false)
                .HasColumnName("student_name");
            entity.Property(e => e.StudentScore).HasColumnName("student_score");
        });

        modelBuilder.Entity<VTrackDepartmentBranchDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_track_department_branch_details", "MangerViews");

            entity.Property(e => e.BranchName)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("branch_name");
            entity.Property(e => e.CreationTime).HasColumnName("creation_time");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("department_name");
            entity.Property(e => e.Status)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("status");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
        });

        modelBuilder.Entity<VTrackIntakeDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("v_track_intake_details", "MangerViews");

            entity.Property(e => e.IntakeName)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("intake_name");
            entity.Property(e => e.IsIntakeActive).HasColumnName("is_intake_active");
            entity.Property(e => e.IsLinkActive).HasColumnName("is_link_active");
            entity.Property(e => e.IsTrackActive).HasColumnName("is_track_active");
            entity.Property(e => e.OverallStatus)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("overall_status");
            entity.Property(e => e.TrackCreationTime).HasColumnName("track_creation_time");
            entity.Property(e => e.TrackName)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("track_name");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
