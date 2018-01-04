using System;
using System.Threading.Tasks;
using Accidis.WebServices.Models;
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
				RequiredLength = AecCredentialsGenerator.PinCodeLength,
				RequireLowercase = false,
				RequireNonLetterOrDigit = false,
				RequireUppercase = false
			};

			return manager;
		}

		public static async Task<bool> CreateDefaultUserIfStoreIsEmptyAsync(string username, string password)
		{
			using(var userManager = Create())
			{
				if(await userManager.Store.IsUserStoreEmptyAsync())
				{
					await userManager.CreateAsync(new AecUser {UserName = username}, password);
					return true;
				}
				return false;
			}
		}
	}
}
