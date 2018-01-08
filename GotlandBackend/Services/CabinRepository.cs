using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class CabinRepository
	{
		public async Task<CabinClass[]> GetAllClasses()
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<CabinClass>("select * from [CabinClass] order by [No]");
				return result.ToArray();
			}
		}
	}
}
