using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class DayBookingRepository
	{
		readonly CredentialsGenerator _credentialsGenerator;

		public DayBookingRepository(CredentialsGenerator credentialsGenerator)
		{
			_credentialsGenerator = credentialsGenerator;
		}

		public async Task<string> CreateAsync(Event evnt, DayBookingSource booking)
		{
			SoloBookingSource.Validate(booking);

			using (var db = DbUtil.Open())
			{
				string reference = _credentialsGenerator.GenerateDayBookingReference();
				await db.ExecuteScalarAsync<Guid>("insert into [DayBooking] ([EventId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [Gender], [Dob], [Food], [TypeId]) " +
												  "values (@EventId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @Gender, @Dob, @Food, @TypeId)",
					new
					{
						EventId = evnt.Id,
						Reference = reference,
						FirstName = booking.FirstName,
						LastName = booking.LastName,
						Email = booking.Email,
						PhoneNo = booking.PhoneNo,
						Gender = booking.Gender,
						Dob = booking.Dob,
						Food = booking.Food,
						TypeId = booking.TypeId
					});

				return reference;
			}
		}


		public async Task DeleteAsync(DayBooking booking)
		{
			using (var db = DbUtil.Open())
				await db.ExecuteAsync("delete from [DayBooking] where [Id] = @Id", new { Id = booking.Id });
		}

		public async Task<DayBooking> FindByReferenceAsync(string reference)
		{
			using (var db = DbUtil.Open())
				return await FindByReferenceAsync(db, reference);
		}

		public async Task<DayBooking> FindByReferenceAsync(SqlConnection db, string reference)
		{
			var result = await db.QueryAsync<DayBooking>("select * from [DayBooking] where [Reference] = @Reference", new { Reference = reference });
			return result.FirstOrDefault();
		}

		public async Task<DayBooking[]> GetListAsync(Event evnt)
		{
			using (var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<DayBooking>("select * from [DayBooking] where [EventId] = @EventId order by [Created] desc",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}

		public async Task<DayBookingType[]> GetTypesAsync()
		{
			using (var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<DayBookingType>("select * from [DayBookingType] order by [Order]");
				return result.ToArray();
			}
		}

		public async Task UpdateAsync(Event evnt, DayBookingSource source)
		{
			SoloBookingSource.Validate(source);

			using (var db = DbUtil.Open())
			{
				var booking = await FindByReferenceAsync(db, source.Reference);
				if (null == booking || booking.EventId != evnt.Id)
					throw new BookingException($"Day booking with reference {source.Reference} not found or not in active event.");

				await db.ExecuteAsync("update [DayBooking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [Gender] = @Gender, [Dob] = @Dob, [Food] = @Food, [TypeId] = @TypeId, [PaymentConfirmed] = @PaymentConfirmed, [Updated] = sysdatetime() where [Id] = @Id",
					new
					{
						Id = booking.Id,
						FirstName = source.FirstName,
						LastName = source.LastName,
						Email = source.Email,
						PhoneNo = source.PhoneNo,
						Gender = source.Gender,
						Dob = source.Dob,
						Food = source.Food,
						TypeId = source.TypeId,
						PaymentConfirmed = source.PaymentConfirmed
					});
			}
		}
	}
}
