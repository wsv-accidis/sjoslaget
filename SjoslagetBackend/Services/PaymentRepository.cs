using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class PaymentRepository
	{
		public async Task CreateAsync(Booking booking, decimal amount)
		{
			using(var db = SjoslagetDb.Open())
				await db.ExecuteAsync("insert into [BookingPayment] (BookingId, Amount) values (@BookingId, @Amount)",
					new {BookingId = booking.Id, Amount = amount});
		}

		public async Task<PaymentSummary> GetSumOfPaymentsByBookingAsync(Booking booking)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryFirstOrDefaultAsync<PaymentSummary>("select sum([Amount]) [Total], max([Created]) [Latest] from [BookingPayment] where [BookingId] = @BookingId group by [BookingId]",
					new {BookingId = booking.Id});

				return result ?? PaymentSummary.Empty;
			}
		}
	}
}
