using System.Data.SqlClient;
using System.Web.Configuration;

namespace Accidis.Sjoslaget.WebService.Db
{
	public sealed class SjoslagetDb
	{
		public static string ConnectionString => WebConfigurationManager.ConnectionStrings["default"].ConnectionString;

		public static SqlConnection Open()
		{
			return new SqlConnection(ConnectionString);
		}
	}
}
