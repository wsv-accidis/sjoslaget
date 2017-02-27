using System.Data;
using System.Data.SqlClient;
using Accidis.Sjoslaget.WebService.Db;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Db
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public sealed class SjoslagetDbTest
	{
		[TestMethod]
		public void ShouldConnect()
		{
			SqlConnection db = null;
			try
			{
				db = SjoslagetDb.Open();
				db.Open();
				Assert.AreEqual(ConnectionState.Open, db.State);
			}
			finally
			{
				db?.Dispose();
			}
		}
	}
}
