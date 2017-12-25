using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Services;
using Dapper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class DeletedBookingRepositoryTest
	{
		[TestMethod]
		public async Task GivenExistingBooking_WhenDeleted_ShouldCeaseToExist()
		{
			var repository = BookingRepositoryTest.GetBookingRepositoryForTest();
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var booking = await BookingRepositoryTest.GetNewlyCreatedBookingForTestAsync(cruise, repository);

			Assert.AreNotEqual(Guid.Empty, booking.Id);
			await repository.DeleteAsync(booking);

			var deletedBooking = await repository.FindByReferenceAsync(booking.Reference);
			Assert.IsNull(deletedBooking);

			deletedBooking = await repository.FindByIdAsync(booking.Id);
			Assert.IsNull(deletedBooking);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenDeleted_ShouldLeaveRecordInDeletedBookings()
		{
			var repository = BookingRepositoryTest.GetBookingRepositoryForTest();
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var booking = await BookingRepositoryTest.GetNewlyCreatedBookingForTestAsync(cruise, repository);

			var paymentRepository = PaymentRepositoryTest.GetPaymentRepositoryForTest();
			const decimal amountPaid = 10m;
			await paymentRepository.CreateAsync(booking, amountPaid);

			await repository.DeleteAsync(booking);

			var deletedBookingRepository = GetDeletedBookingRepositoryForTest();
			var deleted = (await deletedBookingRepository.FindByReferenceAsync(booking.Reference)).FirstOrDefault();

			Assert.IsNotNull(deleted);
			Assert.AreEqual(booking.CruiseId, deleted.CruiseId);
			Assert.AreEqual(booking.Reference, deleted.Reference);
			Assert.AreEqual(booking.FirstName, deleted.FirstName);
			Assert.AreEqual(booking.LastName, deleted.LastName);
			Assert.AreEqual(booking.Email, deleted.Email);
			Assert.AreEqual(booking.PhoneNo, deleted.PhoneNo);
			Assert.AreEqual(booking.TotalPrice, deleted.TotalPrice);
			Assert.AreEqual(amountPaid, deleted.AmountPaid);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenDeleted_SubTablesShouldBeCleared()
		{
			var source = BookingRepositoryTest.GetSimpleBookingForTest();
			source.Products.Add(BookingRepositoryTest.GetProductForTest());

			var repository = BookingRepositoryTest.GetBookingRepositoryForTest();
			var cruise = await CruiseRepositoryTest.GetCruiseForTestAsync();
			var result = await repository.CreateAsync(cruise, source);

			var booking = await repository.FindByReferenceAsync(result.Reference);
			var paymentRepository = PaymentRepositoryTest.GetPaymentRepositoryForTest();
			await paymentRepository.CreateAsync(booking, 123.45m);

			await repository.DeleteAsync(booking);

			// The booking now has cabins, pax, products and a payment
			// If we add more data in subtables remember to add and check for it here
			// All relevant tables should be empty now

			using(var db = SjoslagetDb.Open())
			{
				Assert.AreEqual(0, db.ExecuteScalar<int>("select count(*) from [Booking]"));
				Assert.AreEqual(0, db.ExecuteScalar<int>("select count(*) from [BookingCabin]"));
				Assert.AreEqual(0, db.ExecuteScalar<int>("select count(*) from [BookingPax]"));
				Assert.AreEqual(0, db.ExecuteScalar<int>("select count(*) from [BookingPayment]"));
				Assert.AreEqual(0, db.ExecuteScalar<int>("select count(*) from [BookingProduct]"));
			}
		}

		[TestInitialize]
		public void Initialize()
		{
			SjoslagetDbExtensions.InitializeForTest();
		}

		internal static DeletedBookingRepository GetDeletedBookingRepositoryForTest()
		{
			return new DeletedBookingRepository(PaymentRepositoryTest.GetPaymentRepositoryForTest());
		}
	}
}
