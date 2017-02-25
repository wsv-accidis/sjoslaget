using System.Data.SqlClient;
using System.Web.Configuration;

namespace Accidis.Sjoslaget.WebService.Db
{
	sealed class SjoslagetDb
	{
		public static SqlConnection Open()
		{
			return new SqlConnection(WebConfigurationManager.ConnectionStrings["default"].ConnectionString);
		}
	}
}