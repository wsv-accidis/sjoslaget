using System.Data.SqlClient;
using System.Web.Configuration;

namespace Accidis.Sjoslaget.WebService.Db
{
	internal sealed class SqlDb
	{
		public static SqlConnection Open()
		{
			return new SqlConnection(WebConfigurationManager.ConnectionStrings["default"].ConnectionString);
		}
	}
}