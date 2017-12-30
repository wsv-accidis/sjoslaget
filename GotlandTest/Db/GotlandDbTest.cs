using System.Data;
using System.Data.SqlClient;
using Accidis.WebServices.Db;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Gotland.Test.Db
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public sealed class GotlandDbTest
	{
		[TestMethod]
		public void ShouldConnect()
		{
			SqlConnection db = null;
			try
			{
				db = DbUtil.Open();
				Assert.AreEqual(ConnectionState.Open, db.State);
			}
			finally
			{
				db?.Dispose();
			}
		}
	}
}
