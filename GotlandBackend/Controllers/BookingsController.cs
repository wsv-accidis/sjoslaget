using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;

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

		//[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				// TODO Authorize
				//if (!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, reference, StringComparison.InvariantCultureIgnoreCase))
					//return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if (null == booking)
					return NotFound();

				Event activeEvent = await _eventRepository.GetActiveAsync();
				if (!AuthContext.IsAdmin && !booking.EventId.Equals(activeEvent?.Id))
					return BadRequest("Request is unauthorized, or booking belongs to an inactive event.");

				BookingPax[] pax = await _bookingRepository.GetPaxForBookingAsync(booking);

				return this.OkNoCache(BookingSource.FromBooking(booking, pax));
			}
			catch (Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}
	}
}
