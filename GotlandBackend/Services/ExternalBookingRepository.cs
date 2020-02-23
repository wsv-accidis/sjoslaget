using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class ExternalBookingRepository
	{
		public async Task<Guid> CreateAsync(Event evnt, ExternalBookingSource booking)
		{
			using(var db = DbUtil.Open())
			{
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [ExternalBooking] ([EventId], [FirstName], [LastName], [Email], [PhoneNo], [Gender], [Dob], [Food], [TypeId]) " +
															"output inserted.[Id] values " +
															"(@EventId, @FirstName, @LastName, @Email, @PhoneNo, @Gender, @Dob, @Food, @TypeId)",
					new
					{
						EventId = evnt.Id,
						FirstName = booking.FirstName,
						LastName = booking.LastName,
						Email = booking.Email,
						PhoneNo = booking.PhoneNo,
						Gender = booking.Gender,
						Dob = booking.Dob,
						Food = booking.Food,
						TypeId = booking.TypeId
					});

				return id;
			}
		}

		public async Task<ExternalBooking[]> GetListAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<ExternalBooking>("select * from [ExternalBooking] where [EventId] = @EventId order by [Created] desc",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}

		public async Task<ExternalBookingType[]> GetTypesAsync()
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<ExternalBookingType>("select * from [ExternalBookingType] order by [Order]");
				return result.ToArray();
			}
		}
	}
}
