using System.Data.SqlClient;

namespace Accidis.Sjoslaget.WebService.Db
{
	static class SqlExceptionExtensions
	{
		public static bool IsForeignKeyViolation(this SqlException ex)
		{
			return ex.Errors.Count > 0 && ex.Errors[0].Number == 547;
		}

		public static bool IsUniqueKeyViolation(this SqlException ex)
		{
			return ex.Errors.Count > 0 && ex.Errors[0].Number == 2627;
		}
	}
}