using System.Data.SqlClient;
using Accidis.WebServices.Db;

namespace Accidis.Gotland.Test.Db
{
	static class GotlandDbExtensions
	{
		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(GotlandDbTestConfig config = null)
		{
			using(var db = DbUtil.Open())
				db.InitializeForTest(config);
		}

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(this SqlConnection db, GotlandDbTestConfig config = null)
		{
			//if(null == config)
			//	config = GotlandDbTestConfig.Default;
		}
	}
}
