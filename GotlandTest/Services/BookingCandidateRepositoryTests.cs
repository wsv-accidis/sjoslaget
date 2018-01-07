using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Accidis.Gotland.Test.Db;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Db;
using Dapper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Gotland.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class BookingCandidateRepositoryTests
	{
		[TestMethod]
		public async Task GivenManyCompetingCandidates_ShouldProduceOrderedQueue()
		{
			var repository = new BookingCandidateRepository();
			await repository.DeleteAllAsync();

			const int numberOfCandidates = 500;
			var candidates = new List<Guid>();

			// Create hundreds of candidates
			for(int i = 0; i < numberOfCandidates; i++)
			{
				var candidate = new BookingCandidate {FirstName = "Candidate " + i, LastName = "Lastname"};
				Guid id = await repository.CreateAsync(candidate);
				candidates.Add(id);
			}

			const int numberOfRequests = numberOfCandidates * 4;
			var tasks = new List<Task>();

			for(int i = 0; i < numberOfRequests; i++)
			{
				Guid candidateId = candidates[i % numberOfCandidates];
				tasks.Add(repository.EnqueueAsync(candidateId));
			}

			await Task.WhenAll(tasks);

			using(var db = DbUtil.Open())
			{
				int numberOfResults = await db.QueryFirstAsync<int>("select count(*) from [BookingQueue]");
				Assert.AreEqual(numberOfCandidates, numberOfResults, "Not every candidate got into the queue.");

				int numberNotDeleteProtected = await db.QueryFirstAsync<int>("select count(*) from [BookingCandidate] where [DeleteProtected] = 0");
				Assert.AreEqual(0, numberNotDeleteProtected, "Not every candidate is delete protected.");

				int minPlace = await db.QueryFirstAsync<int>("select min([No]) from [BookingQueue]");
				Assert.AreEqual(1, minPlace, "The first candidate does not have No = 1.");

				// Note: It's actually possible for the list to leave gaps because of how SQL Server handles inserts
				// with IDENTITY columns but the conditions of this test are such that it shouldn't happen unless something is b0rken.
				int maxPlace = await db.QueryFirstAsync<int>("select max([No]) from [BookingQueue]");
				Assert.AreEqual(numberOfCandidates, maxPlace, $"The last candidate does not have No = {numberOfCandidates}.");

				// Assume keys and constraints in db will ensure no duplicates, no rows w/o candidates, etc.
			}
		}

		[TestInitialize]
		public void Initialize()
		{
			GotlandDbExtensions.InitializeForTest();
		}
	}
}
