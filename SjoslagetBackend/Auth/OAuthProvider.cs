﻿using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.Owin.Security.OAuth;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class OAuthProvider : OAuthAuthorizationServerProvider
	{
		public override async Task GrantResourceOwnerCredentials(OAuthGrantResourceOwnerCredentialsContext context)
		{
			context.OwinContext.Response.Headers.Add("Access-Control-Allow-Origin", new[] {"*"});

			using(var userManager = UserStore.CreateManager())
			{
				User user = await userManager.FindAsync(context.UserName, context.Password);
				if(null == user)
				{
					context.SetError("invalid_grant", "The user name or password is incorrect.");
					return;
				}

				var identity = await userManager.CreateIdentityAsync(user, context.Options.AuthenticationType);
				context.Validated(identity);
			}
		}

		public override Task ValidateClientAuthentication(OAuthValidateClientAuthenticationContext context)
		{
			context.Validated(); // do not need to validate clients as we will have only one
			return Task.CompletedTask;
		}
	}
}