using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class UsersController : ApiController
	{
		[HttpPost]
		public async Task<IHttpActionResult> Create(User user)
		{
			var userManager = HttpContext.Current.GetSjoslagetUserManager();
			IdentityResult result = await userManager.CreateAsync(user, user.Password);

			if(null == result)
				return InternalServerError();

			if(!result.Succeeded)
			{
				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}

			return Ok();
		}
	}
}
