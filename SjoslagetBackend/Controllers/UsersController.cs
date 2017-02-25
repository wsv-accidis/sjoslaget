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
		readonly UserManager<User, Guid> _userManager;

		public UsersController()
		{
			_userManager = UserStore.CreateManager();
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(User user)
		{
			IdentityResult result = await _userManager.CreateAsync(user, user.Password);

			if(null == result)
				return InternalServerError();

			if(!result.Succeeded)
			{
				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}

			return Ok();
		}

		protected override void Dispose(bool disposing)
		{
			if(disposing)
				_userManager.Dispose();
			base.Dispose(disposing);
		}
	}
}
