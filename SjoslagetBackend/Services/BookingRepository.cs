﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Transactions;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class BookingRepository
	{
		const string LockResource = "Booking";
		const int LockTimeout = 10000;

		readonly CabinRepository _cabinRepository;
		readonly RandomKeyGenerator _randomKeyGenerator;
		readonly SjoslagetUserManager _userManager;

		public BookingRepository(CabinRepository cabinRepository, RandomKeyGenerator randomKeyGenerator, SjoslagetUserManager userManager)
		{
			_cabinRepository = cabinRepository;
			_randomKeyGenerator = randomKeyGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateAsync(Guid cruiseId, BookingSource source)
		{
			BookingSource.Validate(source);
			var booking = Booking.FromSource(source, cruiseId, _randomKeyGenerator.GenerateBookingReference());

			/*
			 * Start a low-isolation transaction just to give us rollback capability in case something fails in the middle of 
			 * the booking. Then acquire a lock (which is automagically tied to the transaction scope) to prevent multiple bookings
			 * being written at once and potentially overcommitting our available cabins.
			 */
			var tranOptions = new TransactionOptions {IsolationLevel = IsolationLevel.ReadUncommitted};
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = SjoslagetDb.Open())
			{
				await db.GetAppLockAsync(LockResource, LockTimeout);
				await CheckAvailability(db, cruiseId, source.Cabins);
				await CreateBooking(db, booking);
				await CreateCabins(db, booking, source.Cabins);

				tran.Complete();
			}

			var password = _randomKeyGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new User {UserName = booking.Reference, IsBooking = true}, password);

			return BookingResult.FromBooking(booking, password);
		}

		public async Task<Booking> FindByIdAsync(Guid id)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<Booking>("select * from [Booking] where [Id] = @Id", new {Id = id});
				return result.FirstOrDefault();
			}
		}

		public async Task<Booking> FindByReferenceAsync(string reference)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<Booking>("select * from [Booking] where [Reference] = @Reference", new {Reference = reference});
				return result.FirstOrDefault();
			}
		}

		async Task CheckAvailability(SqlConnection db, Guid cruiseId, List<BookingSource.Cabin> sourceList)
		{
			Dictionary<Guid, CruiseCabinAvailability> availabilityDict = (await _cabinRepository.GetAvailabilityAsync(db, cruiseId)).ToDictionary(c => c.CabinTypeId, c => c);

			foreach(BookingSource.Cabin cabinSource in sourceList)
			{
				CruiseCabinAvailability availability;
				if(!availabilityDict.TryGetValue(cabinSource.TypeId, out availability))
					throw new BookingException($"Cabin type \"{cabinSource.TypeId}\" does not refer to an active type.");

				availability.Available--;
				if(availability.Available < 0)
					throw new AvailabilityException($"No more cabins of type \"{cabinSource.TypeId}\" are available on this cruise.");
			}
		}

		async Task CreateBooking(SqlConnection db, Booking booking)
		{
			bool createdBooking = false;
			while(!createdBooking)
			{
				try
				{
					Guid id = await db.ExecuteScalarAsync<Guid>("insert into [Booking] ([CruiseId], [Reference], [FirstName], [LastName], [Email], [PhoneNo]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo)",
						new {CruiseId = booking.CruiseId, Reference = booking.Reference, FirstName = booking.FirstName, LastName = booking.LastName, Email = booking.Email, PhoneNo = booking.PhoneNo});

					createdBooking = true;
					booking.Id = id;
				}
				catch(SqlException ex)
				{
					// in the unlikely event that a duplicate reference is generated, simply try again
					if(ex.IsUniqueKeyViolation())
						booking.Reference = _randomKeyGenerator.GenerateBookingReference();
					else
						throw;
				}
			}
		}

		async Task CreateCabins(SqlConnection db, Booking booking, List<BookingSource.Cabin> sourceList)
		{
			int idx = 0;
			foreach(BookingSource.Cabin cabinSource in sourceList)
			{
				var cabin = BookingCabin.FromSource(cabinSource, booking.Id);
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [BookingCabin] ([CruiseId], [BookingId], [CabinTypeId], [Order]) output inserted.[Id] values (@CruiseId, @BookingId, @CabinTypeId, @Order)",
					new {CruiseId = booking.CruiseId, BookingId = booking.Id, CabinTypeId = cabin.CabinTypeId, Order = idx++});

				IEnumerable<BookingPax> pax = cabinSource.Pax.Select(p => BookingPax.FromSource(p, id));
				await db.ExecuteAsync("insert into [BookingPax] ([BookingCabinId], [FirstName], [LastName]) values (@BookingCabinId, @FirstName, @LastName)",
					pax.Select(p => new {BookingCabinId = p.BookingCabinId, FirstName = p.FirstName, LastName = p.LastName}));
			}
		}
	}
}
