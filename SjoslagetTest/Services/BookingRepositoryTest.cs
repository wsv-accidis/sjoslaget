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
		public async Task GivenBookingSourceWithErrors_WhenDataIsPartiallyCorrect_ShouldNotCreateAnyBooking()
		{
			var source = new BookingSource
			{
				FirstName = "Felaktig",
				LastName = "Felaktigsson",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Cabins = new List<BookingSource.Cabin>
				{
					new BookingSource.Cabin
					{
						TypeId = SjoslagetDbExtensions.CabinTypeId,
						Pax = new List<BookingSource.Pax>
						{
							new BookingSource.Pax {FirstName = "This", LastName = "cabin"},
							new BookingSource.Pax {FirstName = "should", LastName = "not"},
							new BookingSource.Pax {FirstName = "be", LastName = "created"},
							new BookingSource.Pax {FirstName = "although", LastName = "it's correct."}
						}
					},
					new BookingSource.Cabin
					{
						TypeId = Guid.NewGuid(), // this will not be a valid cabin type
						Pax = new List<BookingSource.Pax>
						{
							new BookingSource.Pax {FirstName = "This", LastName = "cabin"},
							new BookingSource.Pax {FirstName = "has", LastName = "an"},
							new BookingSource.Pax {FirstName = "invalid", LastName = "cabintype"},
							new BookingSource.Pax {FirstName = "for", LastName = "sure!"}
						}
					}
				}
			};

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
				Assert.AreEqual(0, numberOfPax, "There should not be any booked ´passengers in the database.");
			}
		}

		[TestMethod]
		public async Task GivenMultipleConcurrentBookings_ShouldNotExceedAvailableCabins()
		{
			var source = new BookingSource
			{
				FirstName = "Wilhelm",
				LastName = "Svenselius",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Cabins = new List<BookingSource.Cabin>
				{
					new BookingSource.Cabin
					{
						TypeId = SjoslagetDbExtensions.CabinTypeId,
						Pax = new List<BookingSource.Pax>
						{
							new BookingSource.Pax {FirstName = "Ett", LastName = "Ettson"},
							new BookingSource.Pax {FirstName = "Två", LastName = "Tvåson"},
							new BookingSource.Pax {FirstName = "Tre", LastName = "Treson"},
							new BookingSource.Pax {FirstName = "Fyr", LastName = "Fyrson"}
						}
					}
				}
			};

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

		[TestMethod]
		public async Task GivenValidBookingSource_ShouldCreateBooking()
		{
			var source = new BookingSource
			{
				FirstName = "Wilhelm",
				LastName = "Svenselius",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Cabins = new List<BookingSource.Cabin>
				{
					new BookingSource.Cabin
					{
						TypeId = SjoslagetDbExtensions.CabinTypeId,
						Pax = new List<BookingSource.Pax>
						{
							new BookingSource.Pax {FirstName = "Ett", LastName = "Ettson"},
							new BookingSource.Pax {FirstName = "Två", LastName = "Tvåson"},
							new BookingSource.Pax {FirstName = "Tre", LastName = "Treson"},
							new BookingSource.Pax {FirstName = "Fyr", LastName = "Fyrson"}
						}
					}
				}
			};

			var result = await CreateBookingFromSource(source);
			Assert.IsNotNull(result.Reference);
			Assert.IsNotNull(result.Password);
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
			var result = await sut.CreateAsync(SjoslagetDbExtensions.CruiseId, source);
			return result;
		}
	}
}
