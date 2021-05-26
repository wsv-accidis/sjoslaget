using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class UsersController : ApiController
	{
		readonly Logger _log = LogManager.GetLogger(nameof(UsersController));
		readonly AecUsersController _usersController;

		public UsersController(AecUsersController usersController)
		{
			_usersController = usersController;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> ChangePassword(UserPasswordChange change)
		{
			try
			{
				await _usersController.ChangePassword(change.Username, change.CurrentPassword, change.NewPassword, change.ForceReset);
				return Ok();
			}
			catch(NotFoundException)
			{
				return NotFound();
			}
			catch(InvalidOperationException ex)
			{
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while trying to change a user's password.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Create(AecUser user)
		{
			try
			{
				await _usersController.CreateUser(user);
				return Ok();
			}
			catch(InvalidOperationException ex)
			{
				return BadRequest(ex.Message);
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
				Tuple<string, string> result = await _usersController.ResetPinCode(booking.Reference);
				return Ok(new BookingResult {Reference = result.Item1, Password = result.Item2});
			}
			catch(NotFoundException)
			{
				return NotFound();
			}
			catch(InvalidOperationException ex)
			{
				return BadRequest(ex.Message);
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
