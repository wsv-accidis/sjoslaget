using System.Threading.Tasks;
using Accidis.Gotland.Test.Db;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Gotland.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class EventRepositoryTest
	{
		[TestMethod]
		public async Task GivenActiveEvent_ShouldGetIt()
		{
			var repository = GetEventRepositoryForTest();
			Event evnt = await repository.GetActiveAsync();

			Assert.IsNotNull(evnt);
			Assert.IsTrue(evnt.IsActive);
			Assert.AreEqual(GotlandDbExtensions.EventId, evnt.Id);
		}

		[TestInitialize]
		public void Initialize()
		{
			GotlandDbExtensions.InitializeForTest();
		}

		internal static async Task<Event> GetEventForTestAsync()
		{
			var repository = GetEventRepositoryForTest();
			return await repository.GetActiveAsync();
		}

		internal static EventRepository GetEventRepositoryForTest()
		{
			return new EventRepository();
		}
	}
}
