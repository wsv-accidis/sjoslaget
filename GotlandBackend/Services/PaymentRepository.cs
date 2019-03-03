using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class PaymentRepository : AecPaymentRepository
	{
		public Task CreateAsync(Booking booking, decimal amount)
		{
			return CreateAsync(booking.Id, amount);
		}

		public Task<PaymentSummary> GetSumOfPaymentsByBookingAsync(Booking booking)
		{
			return GetSumOfPaymentsByBookingAsync(booking.Id);
		}
	}
}
