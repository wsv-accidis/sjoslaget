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

			using(var db = DbUtil.Open())
			{
				var reference = _credentialsGenerator.GenerateDayBookingReference();
				await db.ExecuteScalarAsync<Guid>("insert into [DayBooking] ([EventId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [Gender], [Dob], [Food], [TypeId]) " +
				                                  "values (@EventId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @Gender, @Dob, @Food, @TypeId)",
					new
					{
						EventId = evnt.Id,
						Reference = reference,
						booking.FirstName,
						booking.LastName,
						booking.Email,
						booking.PhoneNo,
						booking.Gender,
						booking.Dob,
						booking.Food,
						booking.TypeId
					});

				return reference;
			}
		}

		public async Task DeleteAsync(DayBooking booking)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("delete from [DayBooking] where [Id] = @Id", new { booking.Id });
		}

		public async Task<bool> FindDuplicateAsync(Event evnt, DayBookingSource booking)
		{
			using(var db = DbUtil.Open())
			{
				var exists = await db.ExecuteScalarAsync<int>(
					"select case when exists(select * from [DayBooking] where [EventId] = @EventId and [FirstName] = @FirstName and [LastName] = @LastName and [Email] = @Email and [Dob] = @Dob) then 1 else 0 end",
					new { EventId = evnt.Id, booking.FirstName, booking.LastName, booking.Email, booking.Dob });
				return exists != 0;
			}
		}

		public async Task<DayBooking> FindByReferenceAsync(string reference)
		{
			using(var db = DbUtil.Open())
				return await FindByReferenceAsync(db, reference);
		}

		public async Task<DayBooking> FindByReferenceAsync(SqlConnection db, string reference)
		{
			var result = await db.QueryAsync<DayBooking>("select * from [DayBooking] where [Reference] = @Reference", new { Reference = reference });
			return result.FirstOrDefault();
		}

		public async Task<int> GetCount(Event evnt)
		{
			using(var db = DbUtil.Open())
				return await db.ExecuteScalarAsync<int>("select count(*) from [DayBooking] where [EventId] = @EventId", new { EventId = evnt.Id });
		}

		public async Task<DayBooking[]> GetListAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<DayBooking>("select * from [DayBooking] where [EventId] = @EventId order by [Created] desc",
					new { EventId = evnt.Id });
				return result.ToArray();
			}
		}

		public async Task<DayBookingType[]> GetTypesAsync()
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<DayBookingType>("select * from [DayBookingType] order by [Order]");
				return result.ToArray();
			}
		}

		public async Task UpdateAsync(Event evnt, DayBookingSource source)
		{
			SoloBookingSource.Validate(source);

			using(var db = DbUtil.Open())
			{
				var booking = await FindByReferenceAsync(db, source.Reference);
				if(null == booking || booking.EventId != evnt.Id)
					throw new BookingException($"Day booking with reference {source.Reference} not found or not in active event.");

				await db.ExecuteAsync(
					"update [DayBooking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [Gender] = @Gender, [Dob] = @Dob, [Food] = @Food, [TypeId] = @TypeId, [PaymentConfirmed] = @PaymentConfirmed, [Updated] = sysdatetime() where [Id] = @Id",
					new
					{
						booking.Id,
						source.FirstName,
						source.LastName,
						source.Email,
						source.PhoneNo,
						source.Gender,
						source.Dob,
						source.Food,
						source.TypeId,
						source.PaymentConfirmed
					});
			}
		}

		public async Task UpdateConfirmationSentAsync(DayBooking booking)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("update [DayBooking] set [ConfirmationSent] = sysdatetime() where [Id] = @Id", new { booking.Id });
		}
	}
}