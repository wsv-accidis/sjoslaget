﻿using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
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
		readonly Logger _log = LogManager.GetLogger(typeof(UsersController).Name);
		readonly AecUserSupport _userSupport;

		public UsersController(AecUserSupport userSupport)
		{
			_userSupport = userSupport;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> ChangePassword(UserPasswordChange change)
		{
			try
			{
				await _userSupport.ChangePassword(change.Username, change.CurrentPassword, change.NewPassword, change.ForceReset);
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
				await _userSupport.CreateUser(user);
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
				Tuple<string, string> result = await _userSupport.ResetPinCode(booking.Reference);
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
