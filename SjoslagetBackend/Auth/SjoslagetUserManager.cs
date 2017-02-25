using System;
using System.Web;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class SjoslagetUserManager : UserManager<User, Guid>
	{
		SjoslagetUserManager() : base(new SjoslagetUserStore())
		{
		}

		public new SjoslagetUserStore Store => (SjoslagetUserStore) base.Store;

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
				RequiredLength = 6,
				RequireLowercase = false,
				RequireNonLetterOrDigit = false,
				RequireUppercase = false
			};

			return manager;
		}
	}

	static class SjoslagetUserManagerExtensions
	{
		public static SjoslagetUserManager GetSjoslagetUserManager(this HttpContext context)
		{
			return context.GetOwinContext().Get<SjoslagetUserManager>();
		}
	}
}
