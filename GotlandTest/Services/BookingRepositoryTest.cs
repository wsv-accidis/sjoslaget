using System;
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

			var result = await repository.CreateFromCandidate(evnt, candidate, 1);

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
		public async Task GivenValidCandidate_WhenCreatingBooking_ShouldGetDetailsFromCandidate()
		{
			var candidateRepository = BookingCandidateRepositoryTest.CreateBookingCandidateRepositoryForTest();
			var newCandidate = new BookingCandidate
			{
				FirstName = "Student",
				LastName = "Studentsson",
				Email = "test@example.com",
				PhoneNo = "123456",
				TeamName = "Team Student",
			};

			const int placeInQueue = 1;
			var candidateId = await candidateRepository.CreateAsync(newCandidate);

			var repository = GetBookingRepositoryForTest();
			var evnt = await EventRepositoryTest.GetEventForTestAsync();

			var candidate = await candidateRepository.FindByIdAsync(candidateId);
			var result = await repository.CreateFromCandidate(evnt, candidate, placeInQueue);
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
				userManagerMock.Object);

			return sut;
		}
	}
}
