using System;
using System.Web;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class SjoslagetUserManager : UserManager<User, Guid>
	{
		SjoslagetUserManager() : base(new SjoslagetUserStore())
		{
		}

		public static SjoslagetUserManager Create(IdentityFactoryOptions<SjoslagetUserManager> identityFactoryOptions, IOwinContext context)
		{
			var manager = new SjoslagetUserManager();
			return manager;
		}
	}

	static class SjoslagetUserManagerExtensions
	{
		public static SjoslagetUserManager GetSjoslagetUserManager(this HttpContext context)
		{
			return context.GetOwinContext().GetUserManager<SjoslagetUserManager>();
		}
	}
}
