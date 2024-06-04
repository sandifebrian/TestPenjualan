using Microsoft.EntityFrameworkCore;
using PenjualanMVC.Models.Entities;

namespace PenjualanMVC.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Konfigurasi tambahan jika diperlukan
        }
    }
}
