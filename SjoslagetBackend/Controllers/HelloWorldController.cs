using System.Linq;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public class HelloWorldController : ApiController
	{
		public IHttpActionResult GetHello()
		{
			using(var connection = SjoslagetDb.Open())
			{
				Cruise[] queryResult = connection.Query<Cruise>("select top 1 * from Cruise where IsActive = @IsActive", new {IsActive = true}).ToArray();
				if(!queryResult.Any())
					return NotFound();

				return Ok(queryResult.First().Name);
			}
		}
	}
}