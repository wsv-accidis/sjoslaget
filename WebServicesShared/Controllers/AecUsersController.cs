﻿using System;
using System.Threading.Tasks;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Microsoft.AspNet.Identity;

namespace Accidis.WebServices.Controllers
{
	public sealed class AecUsersController
	{
		readonly AecCredentialsGenerator _credentialsGenerator;
		readonly AecUserManager _userManager;

		public AecUsersController(AecCredentialsGenerator credentialsGenerator, AecUserManager userManager)
		{
			_credentialsGenerator = credentialsGenerator;
			_userManager = userManager;
		}

		public async Task ChangePassword(string userName, string currentPassword, string newPassword, bool forceReset)
		{
			var user = await _userManager.FindByNameAsync(userName);

			if(null == user)
				throw new NotFoundException();
			if(user.IsBooking)
				throw new InvalidOperationException("This operation can't be used to change the PIN code of a booking.");

			IdentityResult result;
			if(forceReset)
			{
				var token = await _userManager.GeneratePasswordResetTokenAsync(user.Id);
				result = await _userManager.ResetPasswordAsync(user.Id, token, newPassword);
			}
			else
			{
				result = await _userManager.ChangePasswordAsync(user.Id, currentPassword, newPassword);
			}

			if(!result.Succeeded)
			{
				var message = string.Join(Environment.NewLine, result.Errors);
				throw new InvalidOperationException(message);
			}
		}

		public async Task CreateUser(AecUser user)
		{
			var result = await _userManager.CreateAsync(new AecUser { UserName = user.UserName }, user.Password);
			if(!result.Succeeded)
			{
				var message = string.Join(Environment.NewLine, result.Errors);
				throw new InvalidOperationException(message);
			}
		}

		public async Task<Tuple<string, string>> ResetPinCode(string bookingRef)
		{
			var user = await _userManager.FindByNameAsync(bookingRef);

			if(null == user)
				throw new NotFoundException();
			if(!user.IsBooking)
				throw new InvalidOperationException("This operation can only be used to reset the PIN code of a booking.");

			var pinCode = _credentialsGenerator.GeneratePinCode();
			var token = await _userManager.GeneratePasswordResetTokenAsync(user.Id);
			var result = await _userManager.ResetPasswordAsync(user.Id, token, pinCode);

			if(result.Succeeded)
				return Tuple.Create(user.UserName, pinCode);

			var message = string.Join(Environment.NewLine, result.Errors);
			throw new InvalidOperationException(message);
		}
	}
}