using System.Linq;
using System.Threading.Tasks;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;

namespace Accidis.WebServices.Services
{
	public sealed class AecPaymentRepository
	{
		public async Task CreateAsync(IBookingPaymentModel booking, decimal amount)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("insert into [BookingPayment] (BookingId, Amount) values (@BookingId, @Amount)",
					new { BookingId = booking.Id, Amount = amount });
			}
		}

		public async Task<Payment[]> GetPaymentsByBookingAsync(IBookingPaymentModel booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Payment>("select [Amount], [Created] from [BookingPayment] where [BookingId] = @BookingId order by [Created]",
					new { BookingId = booking.Id });

				return result.ToArray();
			}
		}

		public async Task<PaymentSummary> GetSumOfPaymentsByBookingAsync(IBookingPaymentModel booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryFirstOrDefaultAsync<PaymentSummary>("select sum([Amount]) [Total], max([Created]) [Latest] from [BookingPayment] where [BookingId] = @BookingId group by [BookingId]",
					new { BookingId = booking.Id });

				return result ?? PaymentSummary.Empty;
			}
		}
	}
}