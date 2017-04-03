using System.Data.SqlClient;
using System.Web.Configuration;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Db
{
	public sealed class SjoslagetDb
	{
		static SjoslagetDb()
		{
			SqlMapper.AddTypeHandler(new GenderTypeHandler());
			SqlMapper.AddTypeHandler(new DateOfBirthTypeHandler());
		}

		public static string ConnectionString => WebConfigurationManager.ConnectionStrings["default"].ConnectionString;

		public static SqlConnection Open()
		{
			var connection = new SqlConnection(ConnectionString);
			connection.Open();
			return connection;
		}
	}
}
