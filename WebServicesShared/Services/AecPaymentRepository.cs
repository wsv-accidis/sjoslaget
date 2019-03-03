using System;
using System.Threading.Tasks;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;

namespace Accidis.WebServices.Services
{
	public class AecPaymentRepository
	{
		protected async Task CreateAsync(Guid bookingId, decimal amount)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("insert into [BookingPayment] (BookingId, Amount) values (@BookingId, @Amount)",
					new {BookingId = bookingId, Amount = amount});
		}

		protected async Task<PaymentSummary> GetSumOfPaymentsByBookingAsync(Guid bookingId)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryFirstOrDefaultAsync<PaymentSummary>("select sum([Amount]) [Total], max([Created]) [Latest] from [BookingPayment] where [BookingId] = @BookingId group by [BookingId]",
					new {BookingId = bookingId});

				return result ?? PaymentSummary.Empty;
			}
		}
	}
}
