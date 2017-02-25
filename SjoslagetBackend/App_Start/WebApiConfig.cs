using System.Web.Http;

namespace Accidis.Sjoslaget.WebService
{
	static class WebApiConfig
	{
		const string BookingReferencePattern = @"[0-9][A-Za-z0-9]{5}";

		public static void Register(HttpConfiguration config)
		{
			config.MapHttpAttributeRoutes();

			config.Routes.MapHttpRoute(
				name: "ControllerActionIdApi",
				routeTemplate: "api/{controller}/{action}/{reference}",
				defaults: new {},
				constraints: new {reference = BookingReferencePattern}
			);

			config.Routes.MapHttpRoute(
				name: "ControllerIdApi",
				routeTemplate: "api/{controller}/{reference}",
				defaults: new {},
				constraints: new {reference = BookingReferencePattern}
			);

			config.Routes.MapHttpRoute(
				name: "ControllerActionApi",
				routeTemplate: "api/{controller}/{action}"
			);

			config.Routes.MapHttpRoute(
				name: "ControllerSimpleApi",
				routeTemplate: "api/{controller}"
			);
		}
	}
}