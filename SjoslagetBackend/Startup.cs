using System;
using System.Web.Http;
using Accidis.Sjoslaget.WebService;
using Accidis.Sjoslaget.WebService.Auth;
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
			var oauthOptions = new OAuthAuthorizationServerOptions
			{
				AccessTokenExpireTimeSpan = TimeSpan.FromMinutes(1),
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

			app.UseOAuthAuthorizationServer(oauthOptions);
			app.UseJwtBearerAuthentication(jwtOptions);

			HttpConfiguration config = new HttpConfiguration();
			WebApiConfig.Register(config);
			app.UseCors(CorsOptions.AllowAll);
			app.UseWebApi(config);
		}
	}
}
