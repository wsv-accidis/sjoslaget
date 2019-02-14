using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Transactions;
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
		readonly AecUserManager _userManager;

		public BookingRepository(AecCredentialsGenerator credentialsGenerator, AecUserManager userManager)
		{
			_credentialsGenerator = credentialsGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateFromCandidateAsync(Event evnt, BookingCandidate candidate, int placeInQueue)
		{
			Booking booking;

			/*
			 * We need a transaction around this to ensure multiple bookings being created from the same candidate.
			 * Unlike Sjöslaget there is no risk of overcomitting passengers since allocation of cabins happens
			 * separate from booking.
			 */
			var tranOptions = new TransactionOptions { IsolationLevel = IsolationLevel.ReadUncommitted };
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				await db.GetAppLockAsync(LockResource, LockTimeout);

				if(0 != await db.ExecuteScalarAsync<int>("select count(*) from [Booking] where [CandidateId] = @Id", new { Id = candidate.Id }))
				{
					_log.Warn($"An attempt was made to create a second booking from the same candidate = {candidate.Id}");
					throw new BookingException("A booking has already been created from this candidate.");
				}

				booking = Booking.FromCandidate(candidate, placeInQueue, evnt.Id, _credentialsGenerator.GenerateBookingReference());
				await CreateBooking(db, candidate.Id, booking);
				tran.Complete();
			}

			var password = _credentialsGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new AecUser { UserName = booking.Reference, IsBooking = true }, password);

			return new BookingResult { Reference = booking.Reference, Password = password };
		}

		public async Task<Booking> FindByReferenceAsync(string reference)
		{
			using(var db = DbUtil.Open())
				return await FindByReferenceAsync(db, reference);
		}

		public async Task<Booking> FindByReferenceAsync(SqlConnection db, string reference)
		{
			var result = await db.QueryAsync<Booking>("select * from [Booking] where [Reference] = @Reference", new { Reference = reference });
			return result.FirstOrDefault();
		}

		public async Task<BookingPax[]> GetPaxForBookingAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingPax>("select * from [BookingPax] where [BookingId] = @Id order by [Order]",
					new { Id = booking.Id });
				return result.ToArray();
			}
		}

		public async Task<BookingQueueStats> GetQueueStatsByReferenceAsync(string reference, DateTime? eventOpening)
		{
			using(var db = DbUtil.Open())
			{
				var queueStats = await db.QueryFirstOrDefaultAsync<QueueStatsRow>("select BC.[TeamSize], BQ.[No], BQ.[Created] from [BookingCandidate] BC " +
					"left join [BookingQueue] BQ on BC.[Id] = [BQ].[CandidateId] " +
					"where BC.[Id] = (select [CandidateId] from [Booking] where [Reference] = @Reference)",
					new { Reference = reference });

				if(null == queueStats)
					return null;

				var aheadInQueue = await db.ExecuteScalarAsync<int>("select SUM(BC.[TeamSize]) from [BookingQueue] BQ " +
					"left join [BookingCandidate] BC on BC.[Id] = [BQ].[CandidateId] where BQ.[No] < @QueueNo",
					new { QueueNo = queueStats.No });

				return new BookingQueueStats
				{
					AheadInQueue = aheadInQueue,
					TeamSize = queueStats.TeamSize,
					QueueLatencyMs = QueueDashboardItem.TryCalculateQueueLatencyMs(eventOpening, queueStats.Created),
					QueueNo = queueStats.No
				};
			}
		}

		public async Task<BookingResult> UpdateAsync(Event evnt, BookingSource source, bool allowUpdateDetails = false)
		{
			BookingSource.ValidatePax(source);
			if(allowUpdateDetails)
				source.ValidateDetails();

			Booking booking;

			/*
			 * See CreateFromCandidateAsync for notes.
			 * Since this method also handles pax the transaction makes it easy to rollback on error.
			 */
			var tranOptions = new TransactionOptions { IsolationLevel = IsolationLevel.ReadUncommitted };
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				await db.GetAppLockAsync(LockResource, LockTimeout);

				booking = await FindByReferenceAsync(db, source.Reference);
				if(null == booking || booking.EventId != evnt.Id)
					throw new BookingException($"Booking with reference {source.Reference} not found or not in active event.");

				await DeletePax(db, booking);
				await CreatePax(db, booking, source.Pax);

				// TODO Calculate totalPrice
				const decimal totalPrice = 0.0m;

				if(allowUpdateDetails)
				{
					await db.ExecuteAsync("update [Booking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [TeamName] = @TeamName, [SpecialRequests] = @SpecialRequests, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new
						{
							FirstName = source.FirstName,
							LastName = source.LastName,
							Email = source.Email,
							PhoneNo = source.PhoneNo,
							TeamName = source.TeamName,
							SpecialRequest = source.SpecialRequest ?? String.Empty,
							TotalPrice = totalPrice,
							Id = booking.Id
						});
				}
				else
				{
					await db.ExecuteAsync("update [Booking] set [SpecialRequest] = @SpecialRequest, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new
						{
							SpecialRequest = source.SpecialRequest ?? String.Empty,
							TotalPrice = totalPrice,
							Id = booking.Id
						});
				}

				tran.Complete();
			}

			return new BookingResult { Reference = booking.Reference };
		}

		async Task CreateBooking(SqlConnection db, Guid candidateId, Booking booking)
		{
			Guid? candidateIdNullable = Guid.Empty == candidateId ? null : new Guid?(candidateId);
			bool createdBooking = false;
			while(!createdBooking)
			{
				try
				{
					Guid id = await db.ExecuteScalarAsync<Guid>("insert into [Booking] ([EventId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [TeamName], [CandidateId], [QueueNo]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @TeamName, @CandidateId, @QueueNo)",
						new
						{
							CruiseId = booking.EventId,
							Reference = booking.Reference,
							FirstName = booking.FirstName,
							LastName = booking.LastName,
							Email = booking.Email,
							PhoneNo = booking.PhoneNo,
							TeamName = booking.TeamName,
							CandidateId = candidateIdNullable,
							QueueNo = booking.QueueNo
						});

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

		async Task CreatePax(SqlConnection db, Booking booking, List<BookingSource.PaxSource> sourceList)
		{
			int paxIdx = 0;
			foreach(BookingSource.PaxSource paxSource in sourceList)
			{
				BookingPax pax = BookingPax.FromSource(paxSource, booking.Id);
				await db.ExecuteAsync("insert into [BookingPax] ([BookingId], [FirstName], [LastName], [Gender], [Dob], [CabinClassMin], [CabinClassPreferred], [CabinClassMax], [SpecialRequest], [Order])"
									  + " values (@BookingId, @FirstName, @LastName, @Gender, @Dob, @CabinClassMin, @CabinClassPreferred, @CabinClassMax, @SpecialRequest, @Order)",
					new
					{
						BookingId = pax.BookingId,
						FirstName = pax.FirstName,
						LastName = pax.LastName,
						Gender = pax.Gender,
						Dob = pax.Dob.ToString(),
						CabinClassMin = pax.CabinClassMin,
						CabinClassPreferred = pax.CabinClassPreferred,
						CabinClassMax = pax.CabinClassMax,
						SpecialRequest = pax.SpecialRequest ?? String.Empty,
						Order = paxIdx++
					});
			}
		}

		async Task DeletePax(SqlConnection db, Booking booking)
		{
			await db.ExecuteAsync("delete from [BookingPax] where [BookingId] = @BookingId", new { BookingId = booking.Id });
		}

		private sealed class QueueStatsRow
		{
			public int TeamSize { get; set; }
			public int No { get; set; }
			public DateTime Created { get; set; }
		}
	}
}
