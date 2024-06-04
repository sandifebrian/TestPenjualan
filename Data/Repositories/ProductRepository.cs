using Microsoft.EntityFrameworkCore;
using PenjualanMVC.Models.Entities;
using System.Data.SqlClient;

namespace PenjualanMVC.Data.Repositories
{
    public interface IProductRepository
    {
        Task<IEnumerable<Product>> GetAllAsync();
        Task<Product> GetByIdAsync(int productId);
        Task AddAsync(Product product);
        Task UpdateAsync(Product product);
        Task DeleteAsync(int productId);
    }

    public class ProductRepository : IProductRepository
    {
        private readonly ApplicationDbContext _context;

        public ProductRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Product>> GetAllAsync()
        {
            return await _context.Products.FromSqlRaw("EXEC GetAllProducts").ToListAsync();
        }

        public async Task<Product> GetByIdAsync(int productId)
        {
            var productIdParam = new SqlParameter("@ProductId", productId);
            var products = await _context.Products.FromSqlRaw("EXEC GetProductById @ProductId", productIdParam).ToListAsync();
            return products.FirstOrDefault();
        }

        public async Task AddAsync(Product product)
        {
            var parameters = new[]
            {
                new SqlParameter("@Name", product.Name),
                new SqlParameter("@Description", product.Description),
                new SqlParameter("@Price", product.Price),
                new SqlParameter("@Stock", product.Stock),
                new SqlParameter("@IsActive", product.IsActive)
            };
            await _context.Database.ExecuteSqlRawAsync("EXEC AddProduct @Name, @Description, @Price, @Stock, @IsActive", parameters);
        }

        public async Task UpdateAsync(Product product)
        {
            var parameters = new[]
            {
                new SqlParameter("@ProductId", product.ProductId),
                new SqlParameter("@Name", product.Name),
                new SqlParameter("@Description", product.Description),
                new SqlParameter("@Price", product.Price),
                new SqlParameter("@Stock", product.Stock),
                new SqlParameter("@IsActive", product.IsActive)
            };
            await _context.Database.ExecuteSqlRawAsync("EXEC UpdateProduct @ProductId, @Name, @Description, @Price, @Stock, @IsActive", parameters);
        }

        public async Task DeleteAsync(int productId)
        {
            var productIdParam = new SqlParameter("@ProductId", productId);
            await _context.Database.ExecuteSqlRawAsync("EXEC DeleteProduct @ProductId", productIdParam);
        }
    }
}
