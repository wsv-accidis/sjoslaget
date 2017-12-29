using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ProductRepository
	{
		public async Task<CruiseProductWithType[]> GetActiveAsync(Cruise cruise)
		{
			using(var db = DbUtil.Open())
				return await GetActiveAsync(db, cruise);
		}

		public async Task<CruiseProductWithType[]> GetActiveAsync(SqlConnection db, Cruise cruise)
		{
			var result = await db.QueryAsync<CruiseProductWithType>("select PT.*, CP.* from [CruiseProduct] CP join [ProductType] PT on CP.[ProductTypeId] = PT.[Id] where CP.[CruiseId] = @Id order by PT.[Order]",
				new {Id = cruise.Id});
			return result.ToArray();
		}

		public async Task<ProductType[]> GetAllAsync()
		{
			using(var db = DbUtil.Open())
				return await GetAllAsync(db);
		}

		public async Task<ProductType[]> GetAllAsync(SqlConnection db)
		{
			var result = await db.QueryAsync<ProductType>("select * from [ProductType] order by [Order]");
			return result.ToArray();
		}

		public async Task<BookingProduct[]> GetProductsForBookingAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingProduct>("select * from [BookingProduct] where [BookingId] = @BookingId",
					new {BookingId = booking.Id});
				return result.ToArray();
			}
		}

		public async Task<ProductCount[]> GetSumOfOrdersByProductAsync(SqlConnection db, Cruise cruise, bool onlyFullyPaid)
		{
			IEnumerable<ProductCount> result;
			var queryParams = new {CruiseId = cruise.Id};

			if(onlyFullyPaid)
			{
				result = await db.QueryAsync<ProductCount>(
					"select [ProductTypeId] [TypeId], SUM([Quantity]) [Count] from [BookingProduct] " +
					"where [BookingId] in ( " +
					"    select [Id] from [Booking] B where " +
					"    B.[CruiseId] = @CruiseId and " +
					"    ISNULL((select sum([Amount]) from [BookingPayment] BP where BP.[BookingId] = B.[Id] group by [BookingId]), 0) >= B.[TotalPrice] " +
					") group by [ProductTypeId]", queryParams);
			}
			else
			{
				result = await db.QueryAsync<ProductCount>("select [ProductTypeId] [TypeId], SUM([Quantity]) [Count] from [BookingProduct] " +
														   "where [CruiseId] = @CruiseId " +
														   "group by [ProductTypeId]", queryParams);
			}

			return result.ToArray();
		}
	}
}
