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
	public sealed class DayBookingsController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly DayBookingRepository _dayBookingRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(DayBookingsController).Name);

		public DayBookingsController(EventRepository eventRepository, DayBookingRepository dayBookingRepository)
		{
			_eventRepository = eventRepository;
			_dayBookingRepository = dayBookingRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(DayBookingSource booking)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				string reference = await _dayBookingRepository.CreateAsync(evnt, booking);
				_log.Info("Created day booking {0}.", reference);

				return Ok();
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating a day booking.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete]
		public async Task<IHttpActionResult> Delete(string reference)
		{
			try
			{
				var booking = await _dayBookingRepository.FindByReferenceAsync(reference);
				if (null == booking)
					return NotFound();

				await _dayBookingRepository.DeleteAsync(booking);
				_log.Info("Deleted day booking {0}.", reference);

				return Ok();
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while deleting the day booking.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				var booking = await _dayBookingRepository.FindByReferenceAsync(reference);
				if (null == booking)
					return NotFound();

				return this.OkNoCache(booking);
			}
			catch (Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the day booking with reference {reference}.");
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
				if (null == evnt)
					return NotFound();

				DayBooking[] bookings = await _dayBookingRepository.GetListAsync(evnt);
				return this.OkNoCache(bookings);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting a list of day bookings.");
				throw;
			}
		}

		[HttpGet]
		public async Task<IHttpActionResult> Types()
		{
			try
			{
				DayBookingType[] types = await _dayBookingRepository.GetTypesAsync();
				return this.OkCacheControl(types, WebConfig.StaticDataMaxAge);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting day booking types.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Update(DayBookingSource booking)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				await _dayBookingRepository.UpdateAsync(evnt, booking);
				return Ok();
			}
			catch (BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while updating the day booking.");
				return BadRequest(ex.Message);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while updating the day booking.");
				throw;
			}
		}
	}
}
