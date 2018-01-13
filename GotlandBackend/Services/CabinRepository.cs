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
	}
}
