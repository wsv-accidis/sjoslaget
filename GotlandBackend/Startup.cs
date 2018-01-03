﻿using System.Web.Http;
using Accidis.Gotland.WebService;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using DryIoc;
using DryIoc.WebApi;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using NLog;
using NLog.Config;
using NLog.Targets;
using Owin;

#if !DEBUG
using Accidis.WebServices.Db;
#endif

[assembly: OwinStartup(typeof(Startup))]

namespace Accidis.Gotland.WebService
{
	public sealed class Startup
	{
		public void Configuration(IAppBuilder app)
		{
			var logger = ConfigureLogging();
			var config = CreateHttpConfiguration();
			var container = ConfigureContainer(config);
			//ConfigureAuth(app, container);
			ConfigureApp(app, config);
			//Bootstrap(logger);
		}

		//static void Bootstrap(Logger logger)
		//{
		//	Task.Run((Action) (async () =>
		//	{
		//		using(var userManager = AecUserManager.Create())
		//		{
		//			if(await userManager.Store.IsUserStoreEmptyAsync())
		//			{
		//				logger.Warn("Database is empty, creating default admin user.");
		//				await userManager.CreateAsync(new User {UserName = AuthConfig.StartupAdminUser}, AuthConfig.StartupAdminPassword);
		//			}
		//		}
		//	}));
		//}

		static void ConfigureApp(IAppBuilder app, HttpConfiguration config)
		{
			app.UseCors(CorsOptions.AllowAll);
			app.UseWebApi(config);
		}

//		static void ConfigureAuth(IAppBuilder app, IContainer container)
//		{
//			var oauthOptions = new OAuthAuthorizationServerOptions
//			{
//				AccessTokenExpireTimeSpan = TimeSpan.FromDays(1),
//				AccessTokenFormat = new JwtAccessTokenFormat(AuthConfig.AudienceSecret, AuthConfig.Audience, AuthConfig.Issuer),
//#if DEBUG
//				AllowInsecureHttp = true,
//#endif
//				Provider = container.Resolve<AecOAuthProvider>(),
//				TokenEndpointPath = new PathString("/api/token"),
//			};

//			var jwtOptions = new JwtBearerAuthenticationOptions
//			{
//				AuthenticationMode = AuthenticationMode.Active,
//				AllowedAudiences = new[] {AuthConfig.Audience},
//				IssuerSecurityTokenProviders = new[] {new SymmetricKeyIssuerSecurityTokenProvider(AuthConfig.Issuer, AuthConfig.AudienceSecret)}
//			};

//			app.UseOAuthAuthorizationServer(oauthOptions);
//			app.UseJwtBearerAuthentication(jwtOptions);
//		}

		static IContainer ConfigureContainer(HttpConfiguration config)
		{
			var container = new Container().WithWebApi(config);

			container.Register<BookingRepository>();
			container.Register<BookingCandidateRepository>();
			container.Register<EventRepository>();
			container.Register<AecCredentialsGenerator>();
//			container.Register<AecUserManager>(Made.Of(() => AecUserManager.Create()), Reuse.Singleton);

			return container;
		}

		static Logger ConfigureLogging()
		{
			var config = new LoggingConfiguration();

#if DEBUG
			var target = new DebuggerTarget {Name = "debug"};
			config.AddTarget(target);
			config.LoggingRules.Add(new LoggingRule("*", LogLevel.Debug, target));
#else
			var target = new DatabaseTarget
			{
				Name = "db",
				ConnectionString = DbUtil.ConnectionString,
				CommandText = "insert into [Log] ([Timestamp], [Level], [Logger], [Message], [Callsite], [Exception], [UserName], [Method], [Url], [RemoteAddress], [LocalAddress]) " +
							  "values (@Timestamp, @Level, @Logger, @Message, @Callsite, @Exception, @UserName, @Method, @Url, @RemoteAddress, @LocalAddress)",
				Parameters =
				{
					new DatabaseParameterInfo("@Timestamp", "${date:universalTime=true}"),
					new DatabaseParameterInfo("@Level", "${level}"),
					new DatabaseParameterInfo("@Logger", "${logger}"),
					new DatabaseParameterInfo("@Message", "${message}"),
					new DatabaseParameterInfo("@Callsite", "${callsite}"),
					new DatabaseParameterInfo("@Exception", "${exception:format=tostring:maxInnerExceptionLevel=2}"),
					new DatabaseParameterInfo("@UserName", "${aspnet-User-Identity}"),
					new DatabaseParameterInfo("@Method", "${aspnet-Request-Method}"),
					new DatabaseParameterInfo("@Url", "${aspnet-Request:serverVariable=HTTP_URL}"),
					new DatabaseParameterInfo("@RemoteAddress", "${aspnet-Request:serverVariable=REMOTE_ADDR}"),
					new DatabaseParameterInfo("@LocalAddress", "${aspnet-Request:serverVariable=LOCAL_ADDR}")
				}
			};
			config.AddTarget(target);
			config.LoggingRules.Add(new LoggingRule("*", LogLevel.Info, target));
#endif
			LogManager.Configuration = config;

			var logger = LogManager.GetLogger(typeof(Startup).Name);
			logger.Debug("Starting up.");
			return logger;
		}

		static HttpConfiguration CreateHttpConfiguration()
		{
			HttpConfiguration config = new HttpConfiguration();
			config.MapHttpAttributeRoutes();

			//config.Routes.MapHttpRoute(
			//	name: "ControllerActionIdApi",
			//	routeTemplate: "api/{controller}/{action}/{reference}",
			//	defaults: new { },
			//	constraints: new {reference = BookingConfig.BookingReferencePattern}
			//);

			//config.Routes.MapHttpRoute(
			//	name: "ControllerIdApi",
			//	routeTemplate: "api/{controller}/{reference}",
			//	defaults: new { },
			//	constraints: new {reference = BookingConfig.BookingReferencePattern}
			//);

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
