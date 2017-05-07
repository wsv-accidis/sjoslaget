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
		public async Task GivenExistingBooking_WhenItIsLocked_ShouldFailToUpdate()
		{
			var repository = GetBookingRepositoryForTest();
			var booking = await GetNewlyCreatedBookingForTestAsync(repository);

			booking.IsLocked = true;
			await repository.UpdateMetadataAsync(booking);

			var updateSource = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			updateSource.Reference = booking.Reference;
			try
			{
				await repository.UpdateAsync(SjoslagetDbExtensions.CruiseId, updateSource);
				Assert.Fail("Update booking did not throw.");
			}
			catch(BookingException)
			{
			}
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenUpdatedWithMoreCabins_ShouldAllowUpToMaximumCapacity()
		{
			Assert.AreEqual(10, Config.NumberOfCabins);
			var repository = GetBookingRepositoryForTest();

			// First create a booking of 8/10 cabins
			var eightOutOfTenCabins = new BookingSource.Cabin[8];
			for(int i = 0; i < eightOutOfTenCabins.Length; i++)
				eightOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());

			var booking = GetBookingForTest(eightOutOfTenCabins);
			var result = await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, booking);

			// Now update it to 9/10 cabins
			var nineOutOfTenCabins = new BookingSource.Cabin[9];
			for(int i = 0; i < nineOutOfTenCabins.Length; i++)
				nineOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());

			booking = GetBookingForTest(nineOutOfTenCabins);
			booking.Reference = result.Reference;
			result = await repository.UpdateAsync(SjoslagetDbExtensions.CruiseId, booking);

			var savedBooking = await repository.FindByReferenceAsync(result.Reference);
			var cabins = await repository.GetCabinsForBookingAsync(savedBooking);
			Assert.AreEqual(9, cabins.Length);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenUpdatedWithTooManyCabins_ShouldPreserveExistingBooking()
		{
			Assert.AreEqual(10, Config.NumberOfCabins);
			var repository = GetBookingRepositoryForTest();

			// First create a booking of 9/10 cabins
			var nineOutOfTenCabins = new BookingSource.Cabin[9];
			for(int i = 0; i < nineOutOfTenCabins.Length; i++)
				nineOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());
			var bookingThatFillsNineOutOfTenCabins = GetBookingForTest(nineOutOfTenCabins);
			await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, bookingThatFillsNineOutOfTenCabins);

			// Then create a booking for the 10th cabin
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Test1", lastName: "Test2")));
			var result = await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, source);

			var booking = await repository.FindByReferenceAsync(result.Reference);
			var cabins = await repository.GetCabinsForBookingAsync(booking);
			Assert.AreEqual(1, cabins.Length);

			// Now try to update it with two bookings
			source = GetBookingForTest(
				GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest()),
				GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest())
			);
			source.Reference = result.Reference;

			try
			{
				result = await repository.UpdateAsync(booking.CruiseId, source);
				Assert.Fail("Update booking did not throw.");
			}
			catch(AvailabilityException)
			{
			}

			// Check to make sure it is still there
			booking = await repository.FindByReferenceAsync(result.Reference);
			cabins = await repository.GetCabinsForBookingAsync(booking);
			Assert.AreEqual(1, cabins.Length);

			var pax = cabins[0].Pax[0];
			Assert.AreEqual(pax.FirstName, "Test1");
			Assert.AreEqual(pax.LastName, "Test2");
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenUpdatedWithValidData_ShouldUpdateBooking()
		{
			var repository = GetBookingRepositoryForTest();

			// Create a booking with one cabin
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			var result = await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, source);

			var booking = await repository.FindByReferenceAsync(result.Reference);
			var cabins = await repository.GetCabinsForBookingAsync(booking);
			var pax = cabins[0].Pax[0];
			Assert.AreEqual(pax.FirstName, "Förnamn1");
			Assert.AreEqual(pax.LastName, "Efternamn1");

			// Now update it to have two cabins
			source = GetBookingForTest(
				GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn2", lastName: "Efternamn2")),
				GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn3", lastName: "Efternamn3"))
			);
			source.Reference = result.Reference;

			result = await repository.UpdateAsync(booking.CruiseId, source);
			Assert.AreEqual(booking.Reference, result.Reference);

			booking = await repository.FindByReferenceAsync(result.Reference);
			cabins = await repository.GetCabinsForBookingAsync(booking);

			pax = cabins[0].Pax[0];
			Assert.AreEqual(pax.FirstName, "Förnamn2");
			Assert.AreEqual(pax.LastName, "Efternamn2");

			pax = cabins[1].Pax[0];
			Assert.AreEqual(pax.FirstName, "Förnamn3");
			Assert.AreEqual(pax.LastName, "Efternamn3");
		}

		[TestMethod]
		public async Task GivenMultipleConcurrentBookings_ShouldNotExceedAvailableCabins()
		{
			var repository = GetBookingRepositoryForTest();
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(4)));
			var tasks = new List<Task>();

			const int overload = 10;
			for(int i = 0; i < Config.NumberOfCabins + overload; i++)
				tasks.Add(repository.CreateAsync(SjoslagetDbExtensions.CruiseId, source));

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

		internal static async Task<Booking> GetNewlyCreatedBookingForTestAsync()
		{
			return await GetNewlyCreatedBookingForTestAsync(GetBookingRepositoryForTest());
		}

		internal static async Task<Booking> GetNewlyCreatedBookingForTestAsync(BookingRepository repository)
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			BookingResult result = await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, source);

			return await repository.FindByReferenceAsync(result.Reference);
		}

		static async Task<BookingResult> CreateBookingFromSource(BookingSource source, BookingRepository repository = null)
		{
			if(null == repository)
				repository = GetBookingRepositoryForTest();

			return await repository.CreateAsync(SjoslagetDbExtensions.CruiseId, source);
		}

		static BookingSource GetBookingForTest(params BookingSource.Cabin[] cabins)
		{
			return new BookingSource
			{
				FirstName = "Testförnamn",
				LastName = "Testefternamn",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Lunch = "15",
				Cabins = new List<BookingSource.Cabin>(cabins)
			};
		}

		static BookingRepository GetBookingRepositoryForTest()
		{
			var userManagerMock = new Mock<SjoslagetUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(new CabinRepository(), new RandomKeyGenerator(), userManagerMock.Object);
			return sut;
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

		static BookingSource.Pax GetPaxForTest(string group = "Group", string firstName = "Testpax", string lastName = "Paxtest", string dob = "000101", string gender = "m", string nationality = "se", int years = 0)
		{
			return new BookingSource.Pax
			{
				Group = group,
				FirstName = firstName,
				LastName = lastName,
				Dob = dob,
				Gender = gender,
				Nationality = nationality,
				Years = years
			};
		}
	}
}
