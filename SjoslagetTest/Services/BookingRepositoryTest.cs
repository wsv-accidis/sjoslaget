using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Dapper;
using Microsoft.AspNet.Identity;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class BookingRepositoryTest
	{
		static readonly SjoslagetDbTestConfig Config = SjoslagetDbTestConfig.Default;

		[TestMethod]
		public async Task GivenBookingSource_WhenCabinHasTooFewPax_ShouldCreateBooking()
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(3)));

			var result = await CreateBookingFromSource(source);
			Assert.IsNotNull(result.Reference);
		}

		[TestMethod]
		public async Task GivenBookingSource_WhenCabinHasTooManyPax_ShouldNotCreateBooking()
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(5)));

			bool failed = false;
			try
			{
				await CreateBookingFromSource(source);
			}
			catch(BookingException)
			{
				failed = true;
			}
			Assert.IsTrue(failed, "Creating an invalid booking should have failed.");
		}

		[TestMethod]
		public async Task GivenBookingSource_WhenDataIsPartiallyCorrect_ShouldNotCreateBooking()
		{
			var source = GetBookingForTest(
				GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(4)),
				GetCabinForTest(Guid.NewGuid(), GetMultiplePaxForTest(4)) // this will not be a valid cabin type
			);

			bool failed = false;
			try
			{
				await CreateBookingFromSource(source);
			}
			catch(BookingException)
			{
				failed = true;
			}
			Assert.IsTrue(failed, "Creating an invalid booking should have failed.");

			using(var db = SjoslagetDb.Open())
			{
				int numberOfBookings = await db.ExecuteScalarAsync<int>("select count(*) from [Booking]");
				Assert.AreEqual(0, numberOfBookings, "There should not be any bookings in the database.");
				int numberOfCabins = await db.ExecuteScalarAsync<int>("select count(*) from [BookingCabin]");
				Assert.AreEqual(0, numberOfCabins, "There should not be any booked cabins in the database.");
				int numberOfPax = await db.ExecuteScalarAsync<int>("select count(*) from [BookingPax]");
				Assert.AreEqual(0, numberOfPax, "There should not be any booked passengers in the database.");
			}
		}

		[TestMethod]
		public async Task GivenBookingSource_WhenDataIsValid_ShouldCreateBooking()
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(4)));

			var result = await CreateBookingFromSource(source);
			Assert.IsNotNull(result.Reference);
			Assert.IsNotNull(result.Password);
		}

		[TestMethod]
		public async Task GivenMultipleConcurrentBookings_ShouldNotExceedAvailableCabins()
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(4)));

			var userManagerMock = new Mock<SjoslagetUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(new CabinRepository(), new RandomKeyGenerator(), userManagerMock.Object);
			var tasks = new List<Task>();

			const int overload = 10;
			for(int i = 0; i < Config.NumberOfCabins + overload; i++)
				tasks.Add(sut.CreateAsync(SjoslagetDbExtensions.CruiseId, source));

			var combinedTask = Task.WhenAll(tasks);
			try
			{
				await combinedTask;
			}
			catch
			{
				// we expect a number of tasks to fail because the cabins ran out
				Assert.IsNotNull(combinedTask.Exception, "Expected some tasks to fail.");
				Assert.AreEqual(overload, combinedTask.Exception.InnerExceptions.Count, "Number of failed tasks does not match expected.");

				foreach(Exception ex in combinedTask.Exception.InnerExceptions)
					Assert.AreEqual(typeof(AvailabilityException), ex.GetType(), $"A task failed for an unexpected reason, got {ex.GetType()} instead of {nameof(AvailabilityException)}.");
			}

			using(var db = SjoslagetDb.Open())
			{
				var numberOfCabins = await db.ExecuteScalarAsync<int>("select count(*) from [BookingCabin]");
				Assert.AreEqual(Config.NumberOfCabins, numberOfCabins, "Wrong number of cabins were booked, found {0}, expected {1}.", numberOfCabins, Config.NumberOfCabins);
			}
		}

		[TestInitialize]
		public void Initialize()
		{
			SjoslagetDbExtensions.InitializeForTest();
		}

		static async Task<BookingResult> CreateBookingFromSource(BookingSource source)
		{
			var userManagerMock = new Mock<SjoslagetUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(new CabinRepository(), new RandomKeyGenerator(), userManagerMock.Object);
			return await sut.CreateAsync(SjoslagetDbExtensions.CruiseId, source);
		}

		static BookingSource GetBookingForTest(params BookingSource.Cabin[] cabins)
		{
			return new BookingSource
			{
				FirstName = "Testförnamn",
				LastName = "Testefternamn",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Cabins = new List<BookingSource.Cabin>(cabins)
			};
		}

		static BookingSource.Cabin GetCabinForTest(Guid cabinTypeId, params BookingSource.Pax[] pax)
		{
			return new BookingSource.Cabin
			{
				TypeId = cabinTypeId,
				Pax = new List<BookingSource.Pax>(pax)
			};
		}

		static BookingSource.Pax[] GetMultiplePaxForTest(int count)
		{
			var result = new BookingSource.Pax[count];
			for(int i = 0; i < count; i++)
				result[i] = GetPaxForTest();
			return result;
		}

		static BookingSource.Pax GetPaxForTest(string firstName = "Testpax", string lastName = "Paxtest")
		{
			return new BookingSource.Pax
			{
				FirstName = firstName,
				LastName = lastName
			};
		}
	}
}
