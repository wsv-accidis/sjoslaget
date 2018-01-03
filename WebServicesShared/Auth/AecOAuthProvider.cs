using System.Security.Claims;
using System.Threading.Tasks;
using Accidis.WebServices.Models;
using Microsoft.Owin.Security.OAuth;

namespace Accidis.WebServices.Auth
{
	public sealed class AecOAuthProvider : OAuthAuthorizationServerProvider
	{
		readonly AecUserManager _userManager;

		public AecOAuthProvider(AecUserManager userManager)
		{
			_userManager = userManager;
		}

		public override async Task GrantResourceOwnerCredentials(OAuthGrantResourceOwnerCredentialsContext context)
		{
			context.OwinContext.Response.Headers.Add("Access-Control-Allow-Origin", new[] {"*"});

			AecUser user = await _userManager.FindAsync(context.UserName, context.Password);

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
