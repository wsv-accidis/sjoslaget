using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class CruiseRepositoryTest
	{
		[TestMethod]
		public async Task GivenActiveCruise_ShouldGetIt()
		{
			var repository = new CruiseRepository();
			Cruise cruise = await repository.GetActiveAsync();

			Assert.IsNotNull(cruise);
			Assert.IsTrue(cruise.IsActive);
			Assert.AreEqual(SjoslagetDbExtensions.CruiseId, cruise.Id);
		}

		[TestInitialize]
		public void Initialize()
		{
			SjoslagetDbExtensions.InitializeForTest();
		}

		internal static async Task<Cruise> GetCruiseForTestAsync()
		{
			var repository = new CruiseRepository();
			return await repository.GetActiveAsync();
		}
	}
}
