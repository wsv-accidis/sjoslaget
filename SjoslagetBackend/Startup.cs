using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Controllers;
using Accidis.WebServices.Db;
using Accidis.WebServices.Services;
using Dapper;
using DryIoc;
using DryIoc.WebApi;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Jwt;
using Microsoft.Owin.Security.OAuth;
using NLog;
using Owin;

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
			Task.Run((Action)(async () =>
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
				TokenEndpointPath = new PathString("/api/token")
			};

			var jwtOptions = new JwtBearerAuthenticationOptions
			{
				AuthenticationMode = AuthenticationMode.Active,
				AllowedAudiences = new[] { AuthConfig.Audience },
				IssuerSecurityKeyProviders = new[] { new SymmetricKeyIssuerSecurityKeyProvider(AuthConfig.Issuer, AuthConfig.AudienceSecret) }
			};

			app.UseOAuthAuthorizationServer(oauthOptions);
			app.UseJwtBearerAuthentication(jwtOptions);
		}

		static IContainer ConfigureContainer(HttpConfiguration config)
		{
			var container = new Container().WithWebApi(config);

			container.Register<AecCredentialsGenerator, CredentialsGenerator>(Reuse.Singleton);
			container.Register<AecOAuthProvider>(Reuse.Singleton);
			container.Register<AecPaymentRepository>(Reuse.Singleton);
			container.Register<AecPaymentsController<Booking>>(Reuse.Singleton);
			container.Register(Made.Of(() => AecUserManager.Create()), Reuse.Singleton);
			container.Register<AecUsersController>(Reuse.Singleton);
			container.Register<BookingCabinsComparer>(Reuse.Singleton);
			container.Register<BookingRepository>(Reuse.Singleton);
			container.Register<CabinRepository>(Reuse.Singleton);
			container.Register<CredentialsGenerator>(Reuse.Singleton);
			container.Register<CruiseRepository>(Reuse.Singleton);
			container.Register<DeletedBookingRepository>(Reuse.Singleton);
			container.Register<PriceCalculator>(Reuse.Singleton);
			container.Register<ProductRepository>(Reuse.Singleton);
			container.Register<ReportingService>(Reuse.Singleton);
			container.Register<ReportRepository>(Reuse.Singleton);

			SqlMapper.AddTypeHandler(new SubCruiseCodeTypeHandler());
			return container;
		}

		static Logger ConfigureLogging()
		{
#if DEBUG
			LogManager.Configuration = AecLoggingConfiguration.CreateForDebug(LogLevel.Debug);
#else
			LogManager.Configuration = AecLoggingConfiguration.CreateForDatabase(DbUtil.ConnectionString, LogLevel.Info);
#endif

			var logger = LogManager.GetLogger(nameof(Startup));
			logger.Debug("Starting up.");
			return logger;
		}

		static HttpConfiguration CreateHttpConfiguration()
		{
			var config = new HttpConfiguration();
			config.MapHttpAttributeRoutes();

			config.Routes.MapHttpRoute(
				"ControllerActionIdApi",
				"api/{controller}/{action}/{reference}",
				new { },
				new { reference = CredentialsGenerator.BookingReferencePattern }
			);

			config.Routes.MapHttpRoute(
				"ControllerIdApi",
				"api/{controller}/{reference}",
				new { },
				new { reference = CredentialsGenerator.BookingReferencePattern }
			);

			config.Routes.MapHttpRoute(
				"ControllerActionApi",
				"api/{controller}/{action}"
			);

			config.Routes.MapHttpRoute(
				"ControllerSimpleApi",
				"api/{controller}"
			);

			return config;
		}
	}
}