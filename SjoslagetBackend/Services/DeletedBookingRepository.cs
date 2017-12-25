using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class DeletedBookingRepository
	{
		readonly PaymentRepository _paymentRepository;

		public DeletedBookingRepository(PaymentRepository paymentRepository)
		{
			_paymentRepository = paymentRepository;
		}

		public async Task<Guid> CreateAsync(Booking booking)
		{
			PaymentSummary payment = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);
			var deleted = DeletedBooking.FromBooking(booking, payment.Total);

			using(var db = SjoslagetDb.Open())
			{
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [DeletedBooking] ([CruiseId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [TotalPrice], [AmountPaid], [Created], [Updated]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @TotalPrice, @AmountPaid, @Created, @Updated)",
					new {CruiseId = deleted.CruiseId, Reference = deleted.Reference, FirstName = deleted.FirstName, LastName = deleted.LastName, Email = deleted.Email, PhoneNo = deleted.PhoneNo, TotalPrice = deleted.TotalPrice, AmountPaid = deleted.AmountPaid, Created = deleted.Created, Updated = deleted.Updated});
				return id;
			}
		}

		public async Task<DeletedBooking[]> FindByReferenceAsync(string reference)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<DeletedBooking>("select * from [DeletedBooking] where [Reference] = @Reference", new {Reference = reference});
				return result.ToArray();
			}
		}
	}
}
