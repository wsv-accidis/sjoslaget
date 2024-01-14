using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Controllers;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class PaymentsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(BookingsController));
		readonly AecPaymentsController<Booking> _paymentsController;

		public PaymentsController(BookingRepository bookingRepository, AecPaymentsController<Booking> paymentsController)
		{
			_bookingRepository = bookingRepository;
			_paymentsController = paymentsController;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Discount(string reference, PaymentSource discount)
		{
			try
			{
				var amount = await _paymentsController.Discount(reference, discount, _bookingRepository.FindByReferenceAsync, _bookingRepository.UpdateDiscountAsync);
				if(amount.HasValue)
					_log.Info("Set discount to {0}% for booking {1}.", amount.Value, reference);

				return Ok();
			}
			catch(NotFoundException)
			{
				return NotFound();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while updating the discount for the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				var payments = await _paymentsController.Get(reference, _bookingRepository.FindByReferenceAsync);
				return this.OkNoCache(payments);
			}
			catch(NotFoundException)
			{
				return NotFound();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting payments for the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Pay(string reference, PaymentSource payment)
		{
			try
			{
				var summary = await _paymentsController.Pay(reference, payment, _bookingRepository.FindByReferenceAsync);

				if(payment.Amount != 0)
					_log.Info("Registered payment of {0} kr for booking {1}.", payment.Amount, reference);

				return Ok(summary);
			}
			catch(NotFoundException)
			{
				return NotFound();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while creating a payment for the booking with reference {reference}.");
				throw;
			}
		}
	}
}