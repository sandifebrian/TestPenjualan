using System.ComponentModel.DataAnnotations;

namespace PenjualanMVC.Models.Entities
{
    public class Product
    {
        [Key]
        public int ProductId { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        [Required]
        [DataType(DataType.Currency)]
        public decimal Price { get; set; }

        [Required]
        public int Stock { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
