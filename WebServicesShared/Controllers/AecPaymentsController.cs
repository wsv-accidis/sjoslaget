using System;
using System.Threading.Tasks;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;

namespace Accidis.WebServices.Controllers
{
	public sealed class AecPaymentsController<TBooking>
		where TBooking : IBookingPaymentModel
	{
		public delegate Task<TBooking> FindBookingByReferenceDelegate(string reference);

		public delegate Task UpdateDiscountDelegate(TBooking booking);

		readonly AecPaymentRepository _paymentRepository;

		public AecPaymentsController(AecPaymentRepository paymentRepository)
		{
			_paymentRepository = paymentRepository;
		}

		public async Task<int?> Discount(string reference, PaymentSource discount, FindBookingByReferenceDelegate findBookingByReference, UpdateDiscountDelegate updateDiscount)
		{
			var booking = await findBookingByReference(reference);
			if(null == booking)
				throw new NotFoundException();

			var amount = Convert.ToInt32(discount.Amount);
			amount = Math.Max(Math.Min(amount, 100), 0);

			if(amount != booking.Discount)
			{
				booking.Discount = amount;
				await updateDiscount(booking);
				return amount;
			}

			return null;
		}

		public async Task<Payment[]> Get(string reference, FindBookingByReferenceDelegate findBookingByReference)
		{
			var booking = await findBookingByReference(reference);
			if(null == booking)
				throw new NotFoundException();

			return await _paymentRepository.GetPaymentsByBookingAsync(booking);
		}

		public async Task<PaymentSummary> Pay(string reference, PaymentSource payment, FindBookingByReferenceDelegate findBookingByReference)
		{
			var booking = await findBookingByReference(reference);
			if(null == booking)
				throw new NotFoundException();

			if(payment.Amount != 0)
				await _paymentRepository.CreateAsync(booking, payment.Amount);

			return await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);
		}
	}
}