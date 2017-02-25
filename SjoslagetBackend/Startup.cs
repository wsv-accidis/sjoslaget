using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Jwt;
using Microsoft.Owin.Security.OAuth;
using Owin;

[assembly: OwinStartup(typeof(Startup))]

namespace Accidis.Sjoslaget.WebService
{
	public sealed class Startup
	{
		public void Configuration(IAppBuilder app)
		{
			ConfigureAuth(app);
			ConfigureApi(app);
			Bootstrap();
		}

		static void Bootstrap()
		{
			Task.Run((Action) (async () =>
			{
				using(var userManager = SjoslagetUserManager.Create())
				{
					if(await userManager.Store.IsUserStoreEmptyAsync())
						await userManager.CreateAsync(new User {UserName = AuthConfig.StartupAdminUser}, AuthConfig.StartupAdminPassword);
				}
			}));
		}

		static void ConfigureApi(IAppBuilder app)
		{
			HttpConfiguration config = new HttpConfiguration();
			WebApiConfig.Register(config);
			app.UseCors(CorsOptions.AllowAll);
			app.UseWebApi(config);
		}

		static void ConfigureAuth(IAppBuilder app)
		{
			var oauthOptions = new OAuthAuthorizationServerOptions
			{
				AccessTokenExpireTimeSpan = TimeSpan.FromDays(1),
				AccessTokenFormat = new JwtAccessTokenFormat(),
				AllowInsecureHttp = true,
				Provider = new OAuthProvider(),
				TokenEndpointPath = new PathString("/api/token"),
			};

			var jwtOptions = new JwtBearerAuthenticationOptions
			{
				AuthenticationMode = AuthenticationMode.Active,
				AllowedAudiences = new[] {AuthConfig.Audience},
				IssuerSecurityTokenProviders = new[] {new SymmetricKeyIssuerSecurityTokenProvider(AuthConfig.Issuer, AuthConfig.AudienceSecret)}
			};

			app.CreatePerOwinContext(SjoslagetUserManager.Create);
			app.UseOAuthAuthorizationServer(oauthOptions);
			app.UseJwtBearerAuthentication(jwtOptions);
		}
	}
}
