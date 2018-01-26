using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Services;
using DryIoc;
using DryIoc.WebApi;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Jwt;
using Microsoft.Owin.Security.OAuth;
using NLog;
using Owin;

#if !DEBUG
using Accidis.WebServices.Db;
#endif

[assembly: OwinStartup(typeof(Startup))]

namespace Accidis.Sjoslaget.WebService
{
	public sealed class Startup
	{
		// ReSharper disable once UnusedMember.Global
		public void Configuration(IAppBuilder app)
		{
			var logger = ConfigureLogging();
			var config = CreateHttpConfiguration();
			var container = ConfigureContainer(config);
			ConfigureAuth(app, container);
			ConfigureApp(app, config);
			Bootstrap(logger);
		}

		static void Bootstrap(Logger logger)
		{
			Task.Run((Action) (async () =>
			{
				if(await AecUserManager.CreateDefaultUserIfStoreIsEmptyAsync(AuthConfig.StartupAdminUser, AuthConfig.StartupAdminPassword))
					logger.Warn("Database was empty, created default admin user.");
			}));
		}

		static void ConfigureApp(IAppBuilder app, HttpConfiguration config)
		{
			app.UseCors(CorsOptions.AllowAll);
			app.UseWebApi(config);
		}

		static void ConfigureAuth(IAppBuilder app, IContainer container)
		{
			var oauthOptions = new OAuthAuthorizationServerOptions
			{
				AccessTokenExpireTimeSpan = TimeSpan.FromDays(1),
				AccessTokenFormat = new JwtAccessTokenFormat(AuthConfig.AudienceSecret, AuthConfig.Audience, AuthConfig.Issuer),
#if DEBUG
				AllowInsecureHttp = true,
#endif
				Provider = container.Resolve<AecOAuthProvider>(),
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
		}

		static IContainer ConfigureContainer(HttpConfiguration config)
		{
			var container = new Container().WithWebApi(config);

			container.Register<AecCredentialsGenerator>();
			container.Register<AecOAuthProvider>();
			container.Register<AecUserManager>(Made.Of(() => AecUserManager.Create()), Reuse.Singleton);
			container.Register<AecUserSupport>();
			container.Register<BookingRepository>();
			container.Register<CabinRepository>();
			container.Register<CruiseRepository>();
			container.Register<DeletedBookingRepository>();
			container.Register<PriceCalculator>();
			container.Register<ProductRepository>();
			container.Register<PaymentRepository>();
			container.Register<ReportingService>();
			container.Register<ReportRepository>();

			return container;
		}

		static Logger ConfigureLogging()
		{
#if DEBUG
			LogManager.Configuration = AecLoggingConfiguration.CreateForDebug(LogLevel.Debug);
#else
			LogManager.Configuration = AecLoggingConfiguration.CreateForDatabase(DbUtil.ConnectionString, LogLevel.Info);
#endif

			var logger = LogManager.GetLogger(typeof(Startup).Name);
			logger.Debug("Starting up.");
			return logger;
		}

		static HttpConfiguration CreateHttpConfiguration()
		{
			HttpConfiguration config = new HttpConfiguration();
			config.MapHttpAttributeRoutes();

			config.Routes.MapHttpRoute(
				name: "ControllerActionIdApi",
				routeTemplate: "api/{controller}/{action}/{reference}",
				defaults: new { },
				constraints: new {reference = AecCredentialsGenerator.BookingReferencePattern}
			);

			config.Routes.MapHttpRoute(
				name: "ControllerIdApi",
				routeTemplate: "api/{controller}/{reference}",
				defaults: new { },
				constraints: new {reference = AecCredentialsGenerator.BookingReferencePattern}
			);

			config.Routes.MapHttpRoute(
				name: "ControllerActionApi",
				routeTemplate: "api/{controller}/{action}"
			);

			config.Routes.MapHttpRoute(
				name: "ControllerSimpleApi",
				routeTemplate: "api/{controller}"
			);

			return config;
		}
	}
}
