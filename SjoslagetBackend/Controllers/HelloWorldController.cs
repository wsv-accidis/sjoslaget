using System;
using System.Web.Http;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public class HelloWorldController : ApiController
	{
		public IHttpActionResult GetHello()
		{
			return Ok(new String[] {"Hello", "World"});
		}
	}
}