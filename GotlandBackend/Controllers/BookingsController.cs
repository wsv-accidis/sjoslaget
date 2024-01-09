using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(BookingsController));
		readonly AecPaymentRepository _paymentRepository;

		public BookingsController(BookingRepository bookingRepository, EventRepository eventRepository, AecPaymentRepository paymentRepository)
		{
			_bookingRepository = bookingRepository;
			_eventRepository = eventRepository;
			_paymentRepository = paymentRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Confirm(string reference)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				await SendBookingConfirmedMailAsync(evnt, booking);
				await _bookingRepository.UpdateConfirmationSentAsync(booking);
				booking.IsLocked = true;
				await _bookingRepository.UpdateLockedAsync(booking);

				_log.Info("Sent confirmation for booking {0}.", booking.Reference);

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while sending a confirmation e-mail.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete]
		public async Task<IHttpActionResult> Delete(string reference)
		{
			try
			{
				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				await _bookingRepository.DeleteAsync(booking);
				_log.Info("Deleted booking {0}.", booking.Reference);

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while deleting the booking.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Empty()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var result = await _bookingRepository.CreateEmptyAsync(evnt);
				_log.Info("Created empty booking {0}.", result.Reference);

				return Ok(result);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating an empty booking.");
				throw;
			}
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				if(IsUnauthorized(reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				Event activeEvent = await _eventRepository.GetActiveAsync();
				if(!AuthContext.IsAdmin && !booking.EventId.Equals(activeEvent?.Id))
					return BadRequest("Request is unauthorized, or booking belongs to an inactive event.");

				BookingPax[] pax = await _bookingRepository.GetPaxForBookingAsync(booking);
				PaymentSummary payment = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);

				BookingSource result = BookingSource.FromBooking(booking, pax, payment);
				if(!AuthContext.IsAdmin)
					result.InternalNotes = null; // Do not leak internal notes to non-admins

				return this.OkNoCache(result);
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> List()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				return this.OkNoCache(await _bookingRepository.GetListAsync(evnt));
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the overview.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Lock(string reference)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				booking.IsLocked = !booking.IsLocked;
				await _bookingRepository.UpdateLockedAsync(booking);
				_log.Info("{0} booking {1}.", booking.IsLocked ? "Locked" : "Unlocked", booking.Reference);

				return Ok(new { IsLocked = booking.IsLocked });
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while sending a confirmation e-mail.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Pax()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				return this.OkNoCache(await _bookingRepository.GetListOfPaxAsync(evnt));
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the overview.");
				throw;
			}
		}

		[HttpPost]
		public async Task<IHttpActionResult> Solo(SoloBookingSource bookingSource)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				if(!evnt.HasOpened)
				{
					_log.Warn("An attempt was made to create a solo booking before the event is open.");
					return BadRequest();
				}

				BookingResult result = await _bookingRepository.CreateSoloAsync(evnt, bookingSource);
				_log.Info("Created solo booking {0}.", result.Reference);

				await SendBookingCreatedMailAsync(evnt, bookingSource, result);
				return Ok(result);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating a solo booking.");
				throw;
			}
		}

		[Authorize]
		[HttpPost]
		public async Task<IHttpActionResult> Update(BookingSource bookingSource)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				if(IsUnauthorized(bookingSource.Reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to update.");

				if(!AuthContext.IsAdmin)
				{
					if(evnt.IsLocked)
						return BadRequest("The event has been locked and the booking can no longer be edited.");
					var bookingIsLocked = await _bookingRepository.IsBookingLockedAsync(bookingSource.Reference);
					if(bookingIsLocked)
						return BadRequest("The booking has been locked and can no longer be edited.");
				}

				BookingResult result = await _bookingRepository.UpdateAsync(evnt, bookingSource, AuthContext.IsAdmin);
				_log.Info("Updated booking {0}.", result.Reference);
				return Ok(result);
			}
			catch(BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while updating the booking.");
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while updating the booking.");
				throw;
			}
		}

		internal static bool IsUnauthorized(string reference)
		{
			return !AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, reference, StringComparison.InvariantCultureIgnoreCase);
		}

		async Task SendBookingCreatedMailAsync(Event evnt, SoloBookingSource source, BookingResult result)
		{
			try
			{
				using(var emailSender = new EmailSender())
					await emailSender.SendBookingCreatedMailAsync(evnt.Name, source.Email, result.Reference, result.Password);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on created booking.");
			}
		}

		async Task SendBookingConfirmedMailAsync(Event evnt, Booking booking)
		{
			try
			{
				using(var emailSender = new EmailSender())
					await emailSender.SendBookingConfirmedMailAsync(evnt.Name, booking.Email, booking.Reference);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on confirmed booking.");
			}
		}
	}
}