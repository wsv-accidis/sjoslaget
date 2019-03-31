using System;
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
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [ExternalBooking] ([EventId], [FirstName], [LastName], [Dob], [PhoneNo], [SpecialRequest], [IsRindiMember], [DayFriday], [DaySaturday]) " +
				                                            "output inserted.[Id] values " +
				                                            "(@EventId, @FirstName, @LastName, @Dob, @PhoneNo, @SpecialRequest, @IsRindiMember, @DayFriday, @DaySaturday)",
					new
					{
						EventId = evnt.Id,
						FirstName = booking.FirstName,
						LastName = booking.LastName,
						Dob = booking.Dob,
						PhoneNo = booking.PhoneNo,
						SpecialRequest = booking.SpecialRequest ?? String.Empty,
						IsRindiMember = booking.IsRindiMember,
						DayFriday = booking.DayFriday,
						DaySaturday = booking.DaySaturday
					});

				return id;
			}
		}
	}
}
