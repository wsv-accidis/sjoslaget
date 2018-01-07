using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Dapper;

namespace Accidis.WebServices.Db
{
	public static class SqlConnectionExtensions
	{
		public static async Task GetAppLockAsync(this SqlConnection db, string resourceName, int timeoutMs)
		{
			var para = new DynamicParameters();
			para.Add("@Resource", resourceName);
			para.Add("@LockMode", "Exclusive");
			para.Add("@LockTimeout", timeoutMs);
			para.Add("@Result", dbType: DbType.Int32, direction: ParameterDirection.ReturnValue);

			await db.ExecuteAsync("sp_getapplock", para, commandType: CommandType.StoredProcedure);
			int result = para.Get<int>("@Result");

			// see https://msdn.microsoft.com/en-us/library/ms189823.aspx
			switch(result)
			{
				case 0:
				case 1:
					return; // all good!
				case -1:
					throw new TimeoutException();
				case -2:
					throw new InvalidOperationException("The lock request was canceled.");
				case -3:
					throw new InvalidOperationException("The lock request was chosen as a deadlock victim.");
				case -999:
					throw new InvalidOperationException("The lock request was invalid, possibly because a transaction is not in progress.");
				default:
					throw new InvalidOperationException($"Acquiring the lock failed with error {result}.");
			}
		}
	}
}
