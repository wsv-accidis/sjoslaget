using System.Data.SqlClient;

namespace Accidis.WebServices.Db
{
	public static class SqlExceptionExtensions
	{
		public static bool IsForeignKeyViolation(this SqlException ex)
		{
			return ex.Errors.Count > 0 && ex.Errors[0].Number == 547;
		}

		public static bool IsUniqueKeyViolation(this SqlException ex)
		{
			return ex.Errors.Count > 0 && (ex.Errors[0].Number == 2627 || ex.Errors[0].Number == 2601);
		}
	}
}
