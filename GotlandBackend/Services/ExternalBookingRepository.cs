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
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [ExternalBooking] ([EventId], [FirstName], [LastName], [Dob], [PhoneNo], [SpecialRequest], [TypeId], [PaymentReceived]) " +
				                                            "output inserted.[Id] values " +
				                                            "(@EventId, @FirstName, @LastName, @Dob, @PhoneNo, @SpecialRequest, @TypeId, @PaymentReceived)",
					new
					{
						EventId = evnt.Id,
						FirstName = booking.FirstName,
						LastName = booking.LastName,
						Dob = booking.Dob,
						PhoneNo = booking.PhoneNo,
						SpecialRequest = booking.SpecialRequest ?? String.Empty,
						TypeId = booking.TypeId,
						PaymentReceived = booking.PaymentReceived
					});

				return id;
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
