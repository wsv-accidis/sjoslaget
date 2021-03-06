﻿using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class CabinRepository
	{
		public async Task<CruiseCabinWithType[]> GetActiveAsync(SqlConnection db, Cruise cruise)
		{
			var result = await db.QueryAsync<CruiseCabinWithType>("select CT.*, CC.* from [CruiseCabin] CC join [CabinType] CT on CC.[CabinTypeId] = CT.[Id] where CC.[CruiseId] = @Id order by CT.[Order]",
				new {Id = cruise.Id});
			return result.ToArray();
		}

		public async Task<CruiseCabinWithType[]> GetActiveAsync(Cruise cruise)
		{
			using(var db = DbUtil.Open())
				return await GetActiveAsync(db, cruise);
		}

		public async Task<CabinType[]> GetAllAsync()
		{
			using(var db = DbUtil.Open())
				return await GetAllAsync(db);
		}

		public async Task<CabinType[]> GetAllAsync(SqlConnection db)
		{
			var result = await db.QueryAsync<CabinType>("select * from [CabinType] order by [Order]");
			return result.ToArray();
		}

		public async Task<CruiseCabinAvailability[]> GetAvailabilityAsync(Cruise cruise)
		{
			using(var db = DbUtil.Open())
				return await GetAvailabilityAsync(db, cruise);
		}

		public async Task<CruiseCabinAvailability[]> GetAvailabilityAsync(SqlConnection db, Cruise cruise)
		{
			var result = await db.QueryAsync<CruiseCabinAvailability>("select cc.[CabinTypeId], cc.[Count] - (select count(*) from [BookingCabin] BC where BC.[CruiseId] = @CruiseId and BC.[CabinTypeId] = cc.[CabinTypeId]) Available " +
																	  "from [CruiseCabin] CC where CC.[CruiseId] = @CruiseId", new {CruiseId = cruise.Id});
			return result.ToArray();
		}
	}
}
