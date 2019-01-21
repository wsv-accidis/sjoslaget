using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Models;
using Accidis.WebServices.Web;
using NLog;
using System;
using System.Threading.Tasks;
using System.Web.Http;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);

		public BookingsController(BookingRepository bookingRepository, EventRepository eventRepository)
		{
			_bookingRepository = bookingRepository;
			_eventRepository = eventRepository;
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				if(IsAuthorized(reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				Event activeEvent = await _eventRepository.GetActiveAsync();
				if(!AuthContext.IsAdmin && !booking.EventId.Equals(activeEvent?.Id))
					return BadRequest("Request is unauthorized, or booking belongs to an inactive event.");

				BookingPax[] pax = await _bookingRepository.GetPaxForBookingAsync(booking);

				return this.OkNoCache(BookingSource.FromBooking(booking, pax));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize]
		[HttpGet]
		[Route("api/bookings/{reference}/queueStats")]
		public async Task<IHttpActionResult> QueueStats(string reference)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				if(IsAuthorized(reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				BookingQueueStats bookingQueueStats = await _bookingRepository.GetQueueStatsByReferenceAsync(reference, evnt.Opening);
				if(null == bookingQueueStats)
					return Ok(new BookingQueueStats());

				return this.OkCacheControl(bookingQueueStats, WebConfig.StaticDataMaxAge);
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize]
		[HttpPost]
		public async Task<IHttpActionResult> Update(BookingSource bookingSource)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			if(IsAuthorized(bookingSource.Reference))
				return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to update.");

			try
			{
				BookingResult result = await _bookingRepository.UpdateAsync(evnt, bookingSource, allowUpdateDetails: AuthContext.IsAdmin);
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

		private static bool IsAuthorized(string reference)
			=> !AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, reference, StringComparison.InvariantCultureIgnoreCase);
	}
}
