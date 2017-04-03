using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class UsersController : ApiController
	{
		readonly SjoslagetUserManager _userManager;

		public UsersController(SjoslagetUserManager userManager)
		{
			_userManager = userManager;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Create(User user)
		{
			IdentityResult result = await _userManager.CreateAsync(new User {UserName = user.UserName}, user.Password);

			if(null == result)
				return InternalServerError();

			if(!result.Succeeded)
			{
				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}

			return Ok();
		}

		[Authorize]
		[HttpGet]
		[Route("api/whoami")]
		public IHttpActionResult WhoAmI()
		{
			string userName = AuthContext.UserName;
			if(String.IsNullOrEmpty(userName))
				throw new InvalidOperationException("Request is authorized, but username was null or empty.");

			return Ok(new {UserName = userName});
		}
	}
}
