using System.Web.Http;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class HelloWorldController : ApiController
	{
		[HttpGet]
		public IHttpActionResult Hello()
		{
			return Ok("Hello, world!");
		}
	}
}
