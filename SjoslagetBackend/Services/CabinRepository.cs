using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class CabinRepository
	{
		public async Task<CruiseCabinWithType[]> GetActiveAsync(SqlConnection db, Guid cruiseId)
		{
			var result = await db.QueryAsync<CruiseCabinWithType>("select CT.*, CC.* from [CruiseCabin] CC join [CabinType] CT on CC.[CabinTypeId] = CT.[Id] where CC.[CruiseId] = @Id order by CT.[Order]",
				new {Id = cruiseId});
			return result.ToArray();
		}

		public async Task<CruiseCabinWithType[]> GetActiveAsync(Guid cruiseId)
		{
			using(var db = SjoslagetDb.Open())
				return await GetActiveAsync(db, cruiseId);
		}

		public async Task<CabinType[]> GetAllAsync()
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<CabinType>("select * from [CabinType] order by [Order]");
				return result.ToArray();
			}
		}

		public async Task<CruiseCabinAvailability[]> GetAvailabilityAsync(SqlConnection db, Guid cruiseId)
		{
			var result = await db.QueryAsync<CruiseCabinAvailability>("select cc.[CabinTypeId], cc.[Count] - (select count(*) from [BookingCabin] BC where BC.[CruiseId] = @CruiseId and BC.[CabinTypeId] = cc.[CabinTypeId]) Available " +
																	  "from [CruiseCabin] CC where CC.[CruiseId] = @CruiseId", new {CruiseId = cruiseId});
			return result.ToArray();
		}
	}
}
