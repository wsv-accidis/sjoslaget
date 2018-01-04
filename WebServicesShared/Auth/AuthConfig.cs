using System.Web.Configuration;

namespace Accidis.WebServices.Auth
{
	public static class AuthConfig
	{
		public static string Audience => WebConfigurationManager.AppSettings["audience"];
		public static string AudienceSecret => WebConfigurationManager.AppSettings["audienceSecret"];
		public static string Issuer => WebConfigurationManager.AppSettings["issuer"];
		public static string StartupAdminUser => WebConfigurationManager.AppSettings["startupAdminUser"];
		public static string StartupAdminPassword => WebConfigurationManager.AppSettings["startupAdminPassword"];
	}
}
