using System;
using System.Linq;
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
		readonly CabinRepository _cabinRepository;
		readonly DayBookingRepository _dayBookingRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(DayBookingsController));

		public DayBookingsController(CabinRepository cabinRepository, DayBookingRepository dayBookingRepository, EventRepository eventRepository)
		{
			_cabinRepository = cabinRepository;
			_dayBookingRepository = dayBookingRepository;
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Capacity()
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var capacity = await GetCapacityByEvent(evnt);
				var count = await _dayBookingRepository.GetCount(evnt);

				return this.OkCacheControl(new DayBookingCapacity { Capacity = capacity, Count = count }, WebConfig.DynamicDataMaxAge);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the day booking capacity.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Confirm(string reference)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var booking = await _dayBookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				await SendDayBookingConfirmedMailAsync(evnt, booking);
				await _dayBookingRepository.UpdateConfirmationSentAsync(booking);

				_log.Info("Sent confirmation for day booking {0}.", booking.Reference);

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while sending a confirmation e-mail.");
				throw;
			}
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(DayBookingSource booking)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var capacity = await GetCapacityByEvent(evnt);
				var count = await _dayBookingRepository.GetCount(evnt);
				if(count >= capacity)
					return Conflict();

				var reference = await _dayBookingRepository.CreateAsync(evnt, booking);
				_log.Info("Created day booking {0}.", reference);

				return Ok();
			}
			catch(Exception ex)
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
				if(null == booking)
					return NotFound();

				await _dayBookingRepository.DeleteAsync(booking);
				_log.Info("Deleted day booking {0}.", reference);

				return Ok();
			}
			catch(Exception ex)
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
				if(null == booking)
					return NotFound();

				return this.OkNoCache(booking);
			}
			catch(Exception ex)
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
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var bookings = await _dayBookingRepository.GetListAsync(evnt);
				return this.OkNoCache(bookings);
			}
			catch(Exception ex)
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
				var types = await _dayBookingRepository.GetTypesAsync();
				return this.OkCacheControl(types, WebConfig.StaticDataMaxAge);
			}
			catch(Exception ex)
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
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				await _dayBookingRepository.UpdateAsync(evnt, booking);
				return Ok();
			}
			catch(BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while updating the day booking.");
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while updating the day booking.");
				throw;
			}
		}

		async Task<int> GetCapacityByEvent(Event evnt)
		{
			var capacity = evnt.Capacity - (await _cabinRepository.GetCapacityByEventAsync(evnt)).Sum(c => c.Capacity);
			// This value could be negative in case of a misconfigured event, make sure we don't return a negative so as not to upset the frontend
			return capacity > 0 ? capacity : 0;
		}

		async Task SendDayBookingConfirmedMailAsync(Event evnt, DayBooking booking)
		{
			try
			{
				using(var emailSender = new EmailSender())
					await emailSender.SendDayBookingConfirmedMailAsync(evnt.Name, booking.Email, booking.Reference);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on confirmed day booking.");
			}
		}
	}
}