using System.Configuration;

namespace Accidis.Sjoslaget.WebService.Auth
{
	static class AuthConfig
	{
		public static string Audience => ConfigurationManager.AppSettings["audience"];
		public static string AudienceSecret => ConfigurationManager.AppSettings["audienceSecret"];
		public static string Issuer => ConfigurationManager.AppSettings["issuer"];
		public static string StartupAdminUser => ConfigurationManager.AppSettings["startupAdminUser"];
		public static string StartupAdminPassword => ConfigurationManager.AppSettings["startupAdminPassword"];
	}
}
