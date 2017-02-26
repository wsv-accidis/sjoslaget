using System;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Auth
{
	public sealed class SjoslagetUserManager : UserManager<User, Guid>
	{
		SjoslagetUserManager() : base(new SjoslagetUserStore())
		{
		}

		internal new SjoslagetUserStore Store => (SjoslagetUserStore) base.Store;

		public static SjoslagetUserManager Create()
		{
			var manager = new SjoslagetUserManager();

			manager.UserValidator = new UserValidator<User, Guid>(manager)
			{
				AllowOnlyAlphanumericUserNames = true,
				RequireUniqueEmail = false
			};

			manager.PasswordValidator = new PasswordValidator
			{
				RequireDigit = false,
				RequiredLength = BookingConfig.PinCodeLength,
				RequireLowercase = false,
				RequireNonLetterOrDigit = false,
				RequireUppercase = false
			};

			return manager;
		}
	}
}
