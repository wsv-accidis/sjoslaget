using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ProductRepository
	{
		public async Task<CruiseProductWithType[]> GetActiveAsync(Guid cruiseId)
		{
			using(var db = SjoslagetDb.Open())
				return await GetActiveAsync(db, cruiseId);
		}

		public async Task<CruiseProductWithType[]> GetActiveAsync(SqlConnection db, Guid cruiseId)
		{
			var result = await db.QueryAsync<CruiseProductWithType>("select PT.*, CP.* from [CruiseProduct] CP join [ProductType] PT on CP.[ProductTypeId] = PT.[Id] where CP.[CruiseId] = @Id order by PT.[Order]",
				new {Id = cruiseId});
			return result.ToArray();
		}

		public async Task<ProductType[]> GetAllAsync()
		{
			using(var db = SjoslagetDb.Open())
				return await GetAllAsync(db);
		}

		public async Task<ProductType[]> GetAllAsync(SqlConnection db)
		{
			var result = await db.QueryAsync<ProductType>("select * from [ProductType] order by [Order]");
			return result.ToArray();
		}
	}
}
