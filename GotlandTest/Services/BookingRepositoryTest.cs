using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Accidis.Gotland.Test.Db;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Models;
using Microsoft.AspNet.Identity;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace Accidis.Gotland.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class BookingRepositoryTest
	{
		[TestMethod]
		public async Task GivenBookingCreatedFromCandidate_WhenCandidateDeleted_ShouldRetainBooking()
		{
			var candidate = await BookingCandidateRepositoryTest.GetNewlyCreatedBookingCandidateForTest();
			var repository = GetBookingRepositoryForTest();
			var evnt = await EventRepositoryTest.GetEventForTestAsync();

			var result = await repository.CreateFromCandidateAsync(evnt, candidate, 1);

			var candidateRepository = BookingCandidateRepositoryTest.CreateBookingCandidateRepositoryForTest();
			await candidateRepository.DeleteAllAsync();

			candidate = await candidateRepository.FindByIdAsync(candidate.Id);
			Assert.IsNull(candidate);

			var booking = await repository.FindByReferenceAsync(result.Reference);

			Assert.IsNotNull(booking);
			Assert.AreEqual(booking.EventId, evnt.Id);
			Assert.IsFalse(booking.CandidateId.HasValue);
		}

		[TestMethod]
		public async Task GivenExistingBooking_WhenUpdatedWithPax_ShouldUpdateBooking()
		{
			var repository = GetBookingRepositoryForTest();
			var evnt = await EventRepositoryTest.GetEventForTestAsync();
			var booking = await GetNewlyCreatedBookingForTest(evnt, repository);

			var source = new BookingSource
			{
				Reference = booking.Reference,
				Pax = new List<BookingSource.PaxSource> { GetPaxSourceForTest(), GetPaxSourceForTest(), GetPaxSourceForTest() }
			};

			var result = await repository.UpdateAsync(evnt, source);
			Assert.AreEqual(booking.Reference, result.Reference);

			booking = await repository.FindByReferenceAsync(result.Reference);
			var pax = await repository.GetPaxForBookingAsync(booking);

			Assert.AreEqual(3, pax.Length);
		}

		[TestMethod]
		public async Task GivenValidCandidate_WhenCreatingBooking_ShouldGetDetailsFromCandidate()
		{
			var candidateRepository = BookingCandidateRepositoryTest.CreateBookingCandidateRepositoryForTest();
			var newCandidate = BookingCandidateRepositoryTest.GetBookingCandidateForTest();

			const int placeInQueue = 1;
			var candidateId = await candidateRepository.CreateAsync(newCandidate);

			var repository = GetBookingRepositoryForTest();
			var evnt = await EventRepositoryTest.GetEventForTestAsync();

			var candidate = await candidateRepository.FindByIdAsync(candidateId);
			var result = await repository.CreateFromCandidateAsync(evnt, candidate, placeInQueue);
			var booking = await repository.FindByReferenceAsync(result.Reference);

			Assert.IsNotNull(booking);
			Assert.AreEqual(booking.EventId, evnt.Id);
			Assert.IsTrue(booking.CandidateId.HasValue);
			Assert.AreEqual(booking.CandidateId.Value, candidateId);
			Assert.AreEqual(booking.FirstName, newCandidate.FirstName);
			Assert.AreEqual(booking.LastName, newCandidate.LastName);
			Assert.AreEqual(booking.Email, newCandidate.Email);
			Assert.AreEqual(booking.PhoneNo, newCandidate.PhoneNo);
			Assert.AreEqual(booking.TeamName, newCandidate.TeamName);
			Assert.AreEqual(placeInQueue, booking.QueueNo);
			Assert.AreEqual(String.Empty, booking.SpecialRequests);
			Assert.AreEqual(0.0m, booking.TotalPrice);
		}

		[TestInitialize]
		public void Initialize()
		{
			GotlandDbExtensions.InitializeForTest();
		}

		internal static BookingRepository GetBookingRepositoryForTest()
		{
			var userManagerMock = new Mock<AecUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<AecUser>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(
				new AecCredentialsGenerator(),
				new TripRepository(),
				userManagerMock.Object);

			return sut;
		}

		internal static async Task<Booking> GetNewlyCreatedBookingForTest(Event evnt, BookingRepository repository)
		{
			var candidate = BookingCandidateRepositoryTest.GetBookingCandidateForTest();
			var result = await repository.CreateFromCandidateAsync(evnt, candidate, 1);
			return await repository.FindByReferenceAsync(result.Reference);
		}

		static BookingSource.PaxSource GetPaxSourceForTest()
		{
			return new BookingSource.PaxSource
			{
				FirstName = "Party",
				LastName = "Partysson",
				Gender = "X",
				Dob = "830412",
				Nationality = "se",
				OutboundTripId = GotlandDbExtensions.OutboundTripId,
				InboundTripId = GotlandDbExtensions.InboundTripId,
				IsStudent = true,
				CabinClassMin = 0,
				CabinClassPreferred = 2,
				CabinClassMax = 3,
				SpecialFood = "Pizza"
			};
		}
	}
}
