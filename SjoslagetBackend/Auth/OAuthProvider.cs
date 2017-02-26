using System.Security.Claims;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.Owin.Security.OAuth;

namespace Accidis.Sjoslaget.WebService.Auth
{
	public sealed class OAuthProvider : OAuthAuthorizationServerProvider
	{
		readonly SjoslagetUserManager _userManager;

		public OAuthProvider(SjoslagetUserManager userManager)
		{
			_userManager = userManager;
		}

		public override async Task GrantResourceOwnerCredentials(OAuthGrantResourceOwnerCredentialsContext context)
		{
			context.OwinContext.Response.Headers.Add("Access-Control-Allow-Origin", new[] {"*"});

			User user = await _userManager.FindAsync(context.UserName, context.Password);

			if(null != user)
			{
				var identity = await _userManager.CreateIdentityAsync(user, context.Options.AuthenticationType);
				if(!user.IsBooking)
					identity.AddClaim(new Claim(ClaimTypes.Role, Roles.Admin));

				context.Validated(identity);
			}
			else
				context.SetError("invalid_grant", "The user name or password is incorrect.");
		}

		public override Task ValidateClientAuthentication(OAuthValidateClientAuthenticationContext context)
		{
			context.Validated(); // do not need to validate clients as we will have only one
			return Task.CompletedTask;
		}
	}
}
