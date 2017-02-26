using System;
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

		public async Task<BookingResult> CreateAsync(Cruise cruise)
		{
			var booking = new Booking {CruiseId = cruise.Id, Reference = _randomKeyGenerator.GenerateBookingReference()};

			using(SqlConnection db = SjoslagetDb.Open())
			{
				bool succeded = false;
				while(!succeded)
				{
					try
					{
						await db.ExecuteAsync("insert into [Booking] ([CruiseId], [Reference]) values (@CruiseId, @Reference)",
							new {CruiseId = booking.CruiseId, Reference = booking.Reference});
						succeded = true;
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
	}
}
