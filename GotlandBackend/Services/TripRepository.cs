using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class TripRepository
	{
		public async Task<Trip[]> GetByEventAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Trip>("select * from [Trip] where [EventId] = @Id",
					new {Id = evnt.Id});
				return result.ToArray();
			}
		}
	}
}
