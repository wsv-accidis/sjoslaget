using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
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
		public async Task GivenBookingSource_ContainingProducts_ShouldSaveProducts()
		{
			var source = GetSimpleBookingForTest();
			source.Products.Add(GetProductForTest());

			var repository = GetBookingRepositoryForTest();
			var result = await CreateBookingFromSource(source, repository);
			Assert.IsNotNull(result.Reference);

			var booking = await repository.FindByReferenceAsync(result.Reference);
			var productRepository = new ProductRepository();
			var productsOnBooking = await productRepository.GetProductsForBookingAsync(booking);

			Assert.AreEqual(1, productsOnBooking.Length);
			Assert.AreEqual(SjoslagetDbExtensions.ProductId, productsOnBooking[0].ProductTypeId);
			Assert.AreEqual(10, productsOnBooking[0].Quantity);
		}

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
		public async Task GivenBookingSource_WhenCruiseIsLocked_ShouldFailToCreate()
		{
			var cruiseRepository = new CruiseRepository();
			var cruise = await cruiseRepository.GetActiveAsync();
			Assert.IsFalse(cruise.IsLocked);
			cruise.IsLocked = true;
			await cruiseRepository.UpdateMetadataAsync(cruise);

			try
			{
				await GetNewlyCreatedBookingForTestAsync(cruise, GetBookingRepositoryForTest());
				Assert.Fail("Create booking did not throw");
			}
			catch(BookingException)
			{
			}
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

			using(var db = DbUtil.Open())
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
			var source = GetSimpleBookingForTest();

			var result = await CreateBookingFromSource(source);
			Assert.IsNotNull(result.Reference);
			Assert.IsNotNull(result.Password);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenCruiseIsLocked_ShouldFailToUpdate()
		{
			var repository = GetBookingRepositoryForTest();
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var booking = await GetNewlyCreatedBookingForTestAsync(cruise, repository);
			Assert.IsFalse(booking.IsLocked);

			var cruiseRepository = new CruiseRepository();
			Assert.IsFalse(cruise.IsLocked);
			cruise.IsLocked = true;
			await cruiseRepository.UpdateMetadataAsync(cruise);

			var updateSource = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			updateSource.Reference = booking.Reference;
			try
			{
				await repository.UpdateAsync(cruise, updateSource);
				Assert.Fail("Update booking did not throw.");
			}
			catch(BookingException)
			{
			}
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenItIsLocked_ShouldFailToUpdate()
		{
			var repository = GetBookingRepositoryForTest();
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var booking = await GetNewlyCreatedBookingForTestAsync(cruise, repository);
			Assert.IsFalse(booking.IsLocked);

			booking.IsLocked = true;
			await repository.UpdateIsLockedAsync(booking);

			var updateSource = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			updateSource.Reference = booking.Reference;
			try
			{
				await repository.UpdateAsync(cruise, updateSource);
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

			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var repository = GetBookingRepositoryForTest();

			// First create a booking of 8/10 cabins
			var eightOutOfTenCabins = new BookingSource.Cabin[8];
			for(int i = 0; i < eightOutOfTenCabins.Length; i++)
				eightOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());

			var booking = GetBookingForTest(eightOutOfTenCabins);
			var result = await repository.CreateAsync(cruise, booking);

			// Now update it to 9/10 cabins
			var nineOutOfTenCabins = new BookingSource.Cabin[9];
			for(int i = 0; i < nineOutOfTenCabins.Length; i++)
				nineOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());

			booking = GetBookingForTest(nineOutOfTenCabins);
			booking.Reference = result.Reference;
			result = await repository.UpdateAsync(cruise, booking);

			var savedBooking = await repository.FindByReferenceAsync(result.Reference);
			var cabins = await repository.GetCabinsForBookingAsync(savedBooking);
			Assert.AreEqual(9, cabins.Length);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenUpdatedWithTooManyCabins_ShouldPreserveExistingBooking()
		{
			Assert.AreEqual(10, Config.NumberOfCabins);

			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var repository = GetBookingRepositoryForTest();

			// First create a booking of 9/10 cabins
			var nineOutOfTenCabins = new BookingSource.Cabin[9];
			for(int i = 0; i < nineOutOfTenCabins.Length; i++)
				nineOutOfTenCabins[i] = GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest());
			var bookingThatFillsNineOutOfTenCabins = GetBookingForTest(nineOutOfTenCabins);
			await repository.CreateAsync(cruise, bookingThatFillsNineOutOfTenCabins);

			// Then create a booking for the 10th cabin
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Test1", lastName: "Test2")));
			var result = await repository.CreateAsync(cruise, source);

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
				result = await repository.UpdateAsync(cruise, source);
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
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();

			// Create a booking with one cabin
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			var result = await repository.CreateAsync(cruise, source);

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

			result = await repository.UpdateAsync(cruise, source);
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
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var source = GetSimpleBookingForTest();
			var tasks = new List<Task>();

			const int overload = 10;
			for(int i = 0; i < Config.NumberOfCabins + overload; i++)
				tasks.Add(repository.CreateAsync(cruise, source));

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

			using(var db = DbUtil.Open())
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

		internal static BookingRepository GetBookingRepositoryForTest()
		{
			var userManagerMock = new Mock<AecUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<AecUser>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(
				new CabinRepository(),
				CruiseRepositoryTest.GetCruiseRepositoryForTest(),
				DeletedBookingRepositoryTest.GetDeletedBookingRepositoryForTest(),
				new PriceCalculator(),
				new ProductRepository(),
				new BookingKeyGenerator(),
				userManagerMock.Object);

			return sut;
		}

		internal static async Task<Booking> GetNewlyCreatedBookingForTestAsync()
		{
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			return await GetNewlyCreatedBookingForTestAsync(cruise, GetBookingRepositoryForTest());
		}

		internal static async Task<Booking> GetNewlyCreatedBookingForTestAsync(Cruise cruise, BookingRepository repository)
		{
			var source = GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetPaxForTest(firstName: "Förnamn1", lastName: "Efternamn1")));
			BookingResult result = await repository.CreateAsync(cruise, source);

			return await repository.FindByReferenceAsync(result.Reference);
		}

		internal static BookingSource.Product GetProductForTest()
		{
			return new BookingSource.Product
			{
				TypeId = SjoslagetDbExtensions.ProductId,
				Quantity = 10
			};
		}

		internal static BookingSource GetSimpleBookingForTest()
		{
			return GetBookingForTest(GetCabinForTest(SjoslagetDbExtensions.CabinTypeId, GetMultiplePaxForTest(4)));
		}

		static async Task<BookingResult> CreateBookingFromSource(BookingSource source, BookingRepository repository = null)
		{
			if(null == repository)
				repository = GetBookingRepositoryForTest();

			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			return await repository.CreateAsync(cruise, source);
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
				Cabins = new List<BookingSource.Cabin>(cabins),
				Products = new List<BookingSource.Product>()
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
