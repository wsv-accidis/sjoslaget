using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class BookingRepository
	{
		readonly RandomKeyGenerator _randomKeyGenerator;
		readonly SjoslagetUserManager _userManager;

		public BookingRepository(RandomKeyGenerator randomKeyGenerator, SjoslagetUserManager userManager)
		{
			_randomKeyGenerator = randomKeyGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateAsync(Cruise cruise, BookingSource source)
		{
			var booking = Booking.FromSource(source, cruise.Id, _randomKeyGenerator.GenerateBookingReference());

			using(SqlConnection db = SjoslagetDb.Open())
			{
				//SqlTransaction tran = null;
				try
				{
					//tran = db.BeginTransaction();

					await CreateBooking(db, booking);
					await CreateCabins(db, booking, source.Cabins);
				}
				finally
				{
					//tran?.Rollback();
				}
			}

			var password = _randomKeyGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new User {UserName = booking.Reference, IsBooking = true}, password);

			return BookingResult.FromBooking(booking, password);
		}

		public async Task<Booking> FindByIdAsync(Guid id)
		{
			using(SqlConnection db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<Booking>("select * from [Booking] where [Id] = @Id", new {Id = id});
				return result.FirstOrDefault();
			}
		}

		public async Task<Booking> FindByReferenceAsync(string reference)
		{
			using(SqlConnection db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<Booking>("select * from [Booking] where [Reference] = @Reference", new {Reference = reference});
				return result.FirstOrDefault();
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
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [BookingCabin] ([BookingId], [CabinTypeId], [Order]) output inserted.[Id] values (@BookingId, @CabinTypeId, @Order)",
					new {BookingId = booking.Id, CabinTypeId = cabin.CabinTypeId, Order = idx++});

				IEnumerable<BookingPax> pax = cabinSource.Pax.Select(p => BookingPax.FromSource(p, id));
				await db.ExecuteAsync("insert into [BookingPax] ([BookingCabinId], [FirstName], [LastName]) values (@BookingCabinId, @FirstName, @LastName)",
					pax.Select(p => new {BookingCabinId = p.BookingCabinId, FirstName = p.FirstName, LastName = p.LastName}));
			}
		}
	}
}
