using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class CabinRepository
	{
		public async Task<CabinClass[]> GetClassesByEventAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<CabinClass>("select * from [CabinClass] CC join [EventCabinClass] ECC on CC.[No] = ECC.[No] where ECC.[EventId] = @EventId order by CC.[No]",
					new {EventId = evnt.Id});
				return result.ToArray();
			}
		}

		public async Task<CabinCapacity[]> GetCapacityByEventAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<CabinCapacity>(
					"select [No], sum([Count]) [Total], sum([Capacity] * [Count]) [Capacity] from [EventCabinClassDetail] " +
					"where [EventId] = @EventId group by [No] order by [No]",
					new {EventId = evnt.Id});
				return result.ToArray();
			}
		}

		public async Task<ClaimedCapacity[]> GetClaimedCapacityByEventAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<ClaimedCapacity>(
					"select [No], " +
					"sum([Capacity] * [Count]) [Capacity], " +
					"(select count(*) from [BookingPax] BP left join [Booking] B on BP.[BookingId] = B.[Id] where B.[EventId] = @EventId and BP.[CabinClassPreferred] = EC.[No]) [Preferred], " +
					"(select count(*) from [BookingPax] BP left join [Booking] B on BP.[BookingId] = B.[Id] where B.[EventId] = @EventId and BP.[CabinClassMin] <= EC.[No] and BP.[CabinClassMax] >= EC.[No]) [Accepted] " +
					"from [EventCabinClassDetail] EC group by [No] order by [No]",
					new {EventId = evnt.Id});

				return result.ToArray();
			}
		}

		public async Task<CabinClassDetail[]> GetCabinClassDetailByEventAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<CabinClassDetail>("select * from [EventCabinClassDetail] where [EventId] = @EventId order by [No], [Capacity]",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}
	}
}
