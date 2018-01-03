using System;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
using Microsoft.AspNet.Identity;

namespace Accidis.WebServices.Auth
{
	public sealed class AecUserManager : UserManager<AecUser, Guid>
	{
		public AecUserManager() : base(new AecUserStore())
		{
		}

		public new AecUserStore Store => (AecUserStore) base.Store;

		public static AecUserManager Create()
		{
			var manager = new AecUserManager();

			manager.UserTokenProvider = new AecUserTokenProvider();

			manager.UserValidator = new UserValidator<AecUser, Guid>(manager)
			{
				AllowOnlyAlphanumericUserNames = true,
				RequireUniqueEmail = false
			};

			manager.PasswordValidator = new PasswordValidator
			{
				RequireDigit = false,
				RequiredLength = BookingKeyGenerator.PinCodeLength,
				RequireLowercase = false,
				RequireNonLetterOrDigit = false,
				RequireUppercase = false
			};

			return manager;
		}
	}
}
