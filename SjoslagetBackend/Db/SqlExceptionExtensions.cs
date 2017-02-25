using System.Data.SqlClient;

namespace Accidis.Sjoslaget.WebService.Db
{
	internal static class SqlExceptionExtensions
	{
		public static bool IsForeignKeyViolation(this SqlException ex)
		{
			return ex.Errors.Count > 0 && ex.Errors[0].Number == 547;
		}
	}
}