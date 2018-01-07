using System;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;
using NLog;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class BookingRepository
	{
		const string LockResource = "Booking";
		const int LockTimeout = 10000;
		readonly AecCredentialsGenerator _credentialsGenerator;

		readonly Logger _log = LogManager.GetLogger(typeof(BookingRepository).Name);

		public BookingRepository(AecCredentialsGenerator credentialsGenerator)
		{
			_credentialsGenerator = credentialsGenerator;
		}

		public async Task<BookingResult> CreateFromCandidate(SqlConnection db, Event evnt, BookingCandidate candidate, int placeInQueue)
		{
			await db.GetAppLockAsync(LockResource, LockTimeout);

			if(0 != await db.ExecuteScalarAsync<int>("select count(*) from [Booking] where [CandidateId] = @Id", new {Id = candidate.Id}))
			{
				_log.Warn($"An attempt was made to create a second booking from the same candidate = {candidate.Id}");
				throw new BookingException("A booking has already been created from this candidate.");
			}

			var booking = Booking.FromCandidate(candidate, placeInQueue, evnt.Id, _credentialsGenerator.GenerateBookingReference());
			await CreateBooking(db, candidate.Id, booking);

			var password = _credentialsGenerator.GeneratePinCode();
			//await _userManager.CreateAsync(new User { UserName = booking.Reference, IsBooking = true }, password);

			return new BookingResult {Reference = booking.Reference, Password = password};
		}

		async Task CreateBooking(SqlConnection db, Guid candidateId, Booking booking)
		{
			bool createdBooking = false;
			while(!createdBooking)
			{
				try
				{
					Guid id = await db.ExecuteScalarAsync<Guid>("insert into [Booking] ([EventId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [TeamName], [CandidateId], [QueueNo]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @TeamName, @CandidateId, @QueueNo)",
						new {CruiseId = booking.EventId, Reference = booking.Reference, FirstName = booking.FirstName, LastName = booking.LastName, Email = booking.Email, PhoneNo = booking.PhoneNo, TeamName = booking.TeamName, CandidateId = candidateId, QueueNo = booking.QueueNo});

					createdBooking = true;
					booking.Id = id;
				}
				catch(SqlException ex)
				{
					// in the unlikely event that a duplicate reference is generated, simply try again
					if(ex.IsUniqueKeyViolation())
						booking.Reference = _credentialsGenerator.GenerateBookingReference();
					else
						throw;
				}
			}
		}
	}
}
