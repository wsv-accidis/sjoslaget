using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class UsersController : ApiController
	{
		readonly Logger _log = LogManager.GetLogger(typeof(UsersController).Name);
		readonly SjoslagetUserManager _userManager;

		public UsersController(SjoslagetUserManager userManager)
		{
			_userManager = userManager;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> ChangePassword(UserPasswordChange change)
		{
			try
			{
				User user = await _userManager.FindByNameAsync(change.Username);

				if(null == user)
					return NotFound();
				if(user.IsBooking)
					return BadRequest("This operation can't be used to change the PIN code of a booking.");

				IdentityResult result = await _userManager.ChangePasswordAsync(user.Id, change.CurrentPassword, change.NewPassword);
				if(result.Succeeded)
					return Ok();

				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while trying to change a user's password.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Create(User user)
		{
			try
			{
				IdentityResult result = await _userManager.CreateAsync(new User {UserName = user.UserName}, user.Password);
				if(result.Succeeded)
					return Ok();

				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while trying to create a user.");
				throw;
			}
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
