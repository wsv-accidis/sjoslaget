using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	sealed class BookingRepository
	{
		public async Task<BookingResult> CreateAsync(Cruise cruise)
		{
			var keyGen = new RandomKeyGenerator();
			var booking = new Booking {CruiseId = cruise.Id, Reference = keyGen.GenerateBookingReference()};

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
							booking.Reference = keyGen.GenerateBookingReference();
						else
							throw;
					}
				}
			}

			var userManager = HttpContext.Current.GetSjoslagetUserManager();
			var password = keyGen.GeneratePinCode();
			await userManager.CreateAsync(new User {UserName = booking.Reference, IsBooking = true}, password);

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
