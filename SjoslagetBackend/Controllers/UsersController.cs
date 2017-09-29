using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.Sjoslaget.WebService.Web;
using Microsoft.AspNet.Identity;
using NLog;
using System;
using System.Threading.Tasks;
using System.Web.Http;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class UsersController : ApiController
	{
		readonly Logger _log = LogManager.GetLogger(typeof(UsersController).Name);
		readonly RandomKeyGenerator _randomKeyGenerator;
		readonly SjoslagetUserManager _userManager;

		public UsersController(RandomKeyGenerator randomKeyGenerator, SjoslagetUserManager userManager)
		{
			_randomKeyGenerator = randomKeyGenerator;
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

				IdentityResult result;
				if(change.ForceReset)
				{
					var token = await _userManager.GeneratePasswordResetTokenAsync(user.Id);
					result = await _userManager.ResetPasswordAsync(user.Id, token, change.NewPassword);
				}
				else
					result = await _userManager.ChangePasswordAsync(user.Id, change.CurrentPassword, change.NewPassword);

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

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> ResetPinCode(BookingReference booking)
		{
			try
			{
				User user = await _userManager.FindByNameAsync(booking.Reference);

				if(null == user)
					return NotFound();
				if(!user.IsBooking)
					return BadRequest("This operation can only be used to reset the PIN code of a booking.");

				string pinCode = _randomKeyGenerator.GeneratePinCode();
				var token = await _userManager.GeneratePasswordResetTokenAsync(user.Id);
				IdentityResult result = await _userManager.ResetPasswordAsync(user.Id, token, pinCode);

				if(result.Succeeded)
					return Ok(new BookingResult {Reference = user.UserName, Password = pinCode});

				string message = string.Join(Environment.NewLine, result.Errors);
				return BadRequest(message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while trying to change a user's password.");
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

			return this.OkNoCache(new {UserName = userName});
		}
	}
}
