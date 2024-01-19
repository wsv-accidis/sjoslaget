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
		readonly CredentialsGenerator _credentialsGenerator;

		readonly Logger _log = LogManager.GetLogger(nameof(BookingRepository));
		readonly AecUserManager _userManager;

		public BookingRepository(CredentialsGenerator credentialsGenerator, AecUserManager userManager)
		{
			_credentialsGenerator = credentialsGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateEmptyAsync(Event evnt)
		{
			var booking = new Booking
			{
				EventId = evnt.Id,
				Reference = _credentialsGenerator.GenerateBookingReference(),
				FirstName = "FirstName",
				LastName = "LastName",
				Email = "info@absolutgotland.se",
				PhoneNo = "0",
				TeamName = "TeamName",
				SpecialRequest = string.Empty,
				InternalNotes = string.Empty
			};

			using(var db = DbUtil.Open())
			{
				await CreateBooking(db, Guid.Empty, booking);
			}

			var password = _credentialsGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new AecUser { UserName = booking.Reference, IsBooking = true }, password);

			return new BookingResult { Reference = booking.Reference, Password = password };
		}

		public async Task<BookingResult> CreateSoloAsync(Event evnt, SoloBookingSource source)
		{
			SoloBookingSource.Validate(source);

			var booking = new Booking
			{
				EventId = evnt.Id,
				Reference = _credentialsGenerator.GenerateBookingReference(),
				FirstName = source.FirstName,
				LastName = source.LastName,
				Email = source.Email,
				PhoneNo = source.PhoneNo,
				TeamName = string.Concat(source.FirstName, ' ', source.LastName),
				GroupName = source.GroupName,
				SpecialRequest = string.Empty,
				InternalNotes = string.Empty
			};

			var pax = new BookingPax
			{
				FirstName = source.FirstName,
				LastName = source.LastName,
				Gender = Gender.FromString(source.Gender),
				Dob = new DateOfBirth(source.Dob),
				Food = source.Food,
				CabinClassMin = 0,
				CabinClassMax = 0,
				CabinClassPreferred = 0
			};

			using(var db = DbUtil.Open())
			{
				await CreateBooking(db, Guid.Empty, booking);
				pax.BookingId = booking.Id;
				await CreatePax(db, pax, 0);
			}

			var password = _credentialsGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new AecUser { UserName = booking.Reference, IsBooking = true }, password);

			return new BookingResult { Reference = booking.Reference, Password = password };
		}

		public async Task<BookingResult> CreateFromCandidateAsync(Event evnt, BookingCandidate candidate, int placeInQueue)
		{
			Booking booking;

			/*
			 * We need a transaction around this to prevent multiple bookings being created from the same candidate.
			 * Unlike Sjöslaget there is no risk of overcommitting passengers since allocation of cabins happens
			 * separate from booking.
			 */
			var tranOptions = new TransactionOptions { IsolationLevel = IsolationLevel.ReadUncommitted };
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				await db.GetAppLockAsync(LockResource, LockTimeout);

				var existingRef = await db.ExecuteScalarAsync<string>("select [Reference] from [Booking] where [CandidateId] = @Id",
					new { candidate.Id });
				if(!string.IsNullOrEmpty(existingRef))
				{
					_log.Warn($"An attempt was made to create a second booking from the same candidate = {candidate.Id}, existing reference = {existingRef}");
					throw new BookingCandidateReusedException(existingRef);
				}

				booking = Booking.FromCandidate(candidate, placeInQueue, evnt.Id, _credentialsGenerator.GenerateBookingReference());
				await CreateBooking(db, candidate.Id, booking);
				tran.Complete();
			}

			var password = _credentialsGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new AecUser { UserName = booking.Reference, IsBooking = true }, password);

			return new BookingResult { Reference = booking.Reference, Password = password };
		}

		public async Task DeleteAsync(Booking booking)
		{
			var user = await _userManager.FindByNameAsync(booking.Reference);
			if(null != user && user.IsBooking)
				await _userManager.DeleteAsync(user);

			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("delete from [Booking] where [Id] = @Id", new { booking.Id });
			}
		}

		public async Task<Booking> FindByReferenceAsync(string reference)
		{
			using(var db = DbUtil.Open())
			{
				return await FindByReferenceAsync(db, reference);
			}
		}

		public async Task<Booking> FindByReferenceAsync(SqlConnection db, string reference)
		{
			return await db.QueryFirstOrDefaultAsync<Booking>("select * from [Booking] where [Reference] = @Reference", new { Reference = reference });
		}

		public async Task<BookingPax[]> GetPaxForBookingAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingPax>("select * from [BookingPax] where [BookingId] = @Id order by [Order]",
					new { booking.Id });
				return result.ToArray();
			}
		}

		public async Task<BookingQueueStats> GetQueueStatsByReferenceAsync(string reference, DateTime? eventOpening)
		{
			using(var db = DbUtil.Open())
			{
				var queueStats = await db.QueryFirstOrDefaultAsync<QueueStatsRow>(
					"select BC.[TeamSize], BQ.[No], BQ.[Created] from [BookingCandidate] BC " +
					"left join [BookingQueue] BQ on BC.[Id] = [BQ].[CandidateId] " +
					"where BC.[Id] = (select [CandidateId] from [Booking] where [Reference] = @Reference)",
					new { Reference = reference });

				if(null == queueStats)
					return null;

				var aheadInQueue = await db.ExecuteScalarAsync<int>(
					"select SUM(BC.[TeamSize]) from [BookingQueue] BQ " +
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

		public async Task<BookingListItem[]> GetListAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingListItem>(
					"select [Id], [Reference], [FirstName], [LastName], [TeamName], [TotalPrice], [QueueNo], [Updated], " +
					"(select count(*) from [BookingPax] where [BookingId] = [Booking].[Id]) NumberOfPax, " +
					"(select sum([NumberOfPax]) from [BookingAllocation] BA where BA.[BookingId] = [Booking].[Id] group by [BookingId]) AllocatedPax, " +
					"(select sum([Amount]) from [BookingPayment] BP where BP.[BookingId] = [Booking].[Id] group by [BookingId]) AmountPaid " +
					"from [Booking] where [EventId] = @EventId",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}

		public async Task<BookingPaxListItem[]> GetListOfPaxAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingPaxListItem>(
					"select P.[Id], B.[Reference], B.[TeamName], P.[FirstName], P.[LastName], P.[Gender], P.[Dob], P.[CabinClassMin], P.[CabinClassPreferred], P.[CabinClassMax] " +
					"from [BookingPax] P left join [Booking] B on P.[BookingId] = B.[Id] " +
					"where B.[EventId] = @EventId",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}

		public async Task<bool> IsBookingLockedAsync(string reference)
		{
			using(var db = DbUtil.Open())
			{
				return await db.QueryFirstOrDefaultAsync<bool>("select [IsLocked] from [Booking] where [Reference] = @Reference", new { Reference = reference });
			}
		}

		public async Task UpdateConfirmationSentAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("update [Booking] set [ConfirmationSent] = sysdatetime() where [Id] = @Id", new { booking.Id });
			}
		}

		public async Task UpdateDiscountAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var totalPrice = await GetTotalPriceForBooking(db, booking.Id, booking.Discount);

				await db.ExecuteAsync("update [Booking] set [Discount] = @Discount, [TotalPrice] = @TotalPrice where [Id] = @Id",
					new { booking.Id, booking.Discount, TotalPrice = totalPrice });
			}
		}

		public async Task UpdateLockedAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("update [Booking] set [IsLocked] = @IsLocked where [Id] = @Id", new { booking.Id, booking.IsLocked });
			}
		}

		public async Task UpdateTotalPriceAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var totalPrice = await GetTotalPriceForBooking(db, booking.Id, booking.Discount);
				await db.ExecuteAsync("update [Booking] set [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
					new
					{
						TotalPrice = totalPrice, booking.Id
					});
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
				var totalPrice = await GetTotalPriceForBooking(db, booking.Id, booking.Discount);

				if(allowUpdateDetails)
					await db.ExecuteAsync(
						"update [Booking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [TeamName] = @TeamName, [GroupName] = @GroupName, [SpecialRequest] = @SpecialRequest, [InternalNotes] = @InternalNotes, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new
						{
							source.FirstName,
							source.LastName,
							source.Email,
							source.PhoneNo,
							source.TeamName,
							source.GroupName,
							SpecialRequest = source.SpecialRequest ?? string.Empty,
							InternalNotes = source.InternalNotes ?? string.Empty,
							TotalPrice = totalPrice,
							booking.Id
						});
				else
					await db.ExecuteAsync("update [Booking] set [SpecialRequest] = @SpecialRequest, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new
						{
							SpecialRequest = source.SpecialRequest ?? string.Empty,
							TotalPrice = totalPrice,
							booking.Id
						});

				tran.Complete();
			}

			return new BookingResult { Reference = booking.Reference };
		}

		async Task CreateBooking(SqlConnection db, Guid candidateId, Booking booking)
		{
			var candidateIdNullable = Guid.Empty == candidateId ? null : new Guid?(candidateId);
			var createdBooking = false;
			while(!createdBooking)
				try
				{
					var id = await db.ExecuteScalarAsync<Guid>(
						"insert into [Booking] ([EventId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [TeamName], [GroupName], [CandidateId], [QueueNo]) output inserted.[Id] values (@EventId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @TeamName, @GroupName, @CandidateId, @QueueNo)",
						new
						{
							booking.EventId,
							booking.Reference,
							booking.FirstName,
							booking.LastName,
							booking.Email,
							booking.PhoneNo,
							booking.TeamName,
							GroupName = booking.GroupName ?? string.Empty,
							CandidateId = candidateIdNullable,
							booking.QueueNo
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

		async Task CreatePax(SqlConnection db, Booking booking, List<BookingSource.PaxSource> sourceList)
		{
			var paxIdx = 0;
			foreach(var paxSource in sourceList)
			{
				var pax = BookingPax.FromSource(paxSource, booking.Id);
				await CreatePax(db, pax, paxIdx++);
			}
		}

		async Task CreatePax(SqlConnection db, BookingPax pax, int idx)
		{
			await db.ExecuteAsync("insert into [BookingPax] ([BookingId], [FirstName], [LastName], [Gender], [Dob], [Food], [CabinClassMin], [CabinClassPreferred], [CabinClassMax], [Order]) " +
			                      "values (@BookingId, @FirstName, @LastName, @Gender, @Dob, @Food, @CabinClassMin, @CabinClassPreferred, @CabinClassMax, @Order)",
				new
				{
					pax.BookingId,
					pax.FirstName,
					pax.LastName,
					pax.Gender,
					Dob = pax.Dob.ToString(),
					pax.Food,
					pax.CabinClassMin,
					pax.CabinClassPreferred,
					pax.CabinClassMax,
					Order = idx
				});
		}

		async Task DeletePax(SqlConnection db, Booking booking)
		{
			await db.ExecuteAsync("delete from [BookingPax] where [BookingId] = @BookingId", new { BookingId = booking.Id });
		}

		async Task<decimal> GetTotalPriceForBooking(SqlConnection db, Guid bookingId, int discount)
		{
			if(discount >= 100)
				return 0m;

			var totalPrice = await db.ExecuteScalarAsync<decimal>(
				"select SUM(BA.[NumberOfPax] * CC.[PricePerPax]) " +
				"from [BookingAllocation] BA " +
				"left join [EventCabinClassDetail] D on D.[Id] = BA.[CabinId] " +
				"left join [EventCabinClass] CC on CC.[No] = D.[No] " +
				"where BA.[BookingId] = @BookingId", new { BookingId = bookingId });

			// Discount (only applies to price of cabins)
			if(discount > 0)
			{
				var discountPrice = totalPrice * (discount / 100m);
				totalPrice -= discountPrice;
			}

			return totalPrice;
		}

		sealed class QueueStatsRow
		{
			public int TeamSize { get; set; }
			public int No { get; set; }
			public DateTime Created { get; set; }
		}
	}
}