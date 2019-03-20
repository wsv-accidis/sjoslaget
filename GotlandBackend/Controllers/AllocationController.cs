using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class AllocationController : ApiController
	{
		readonly AllocationRepository _allocationRepository;
		readonly BookingRepository _bookingRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(AllocationController).Name);

		public AllocationController(AllocationRepository allocationRepository, BookingRepository bookingRepository, EventRepository eventRepository)
		{
			_allocationRepository = allocationRepository;
			_bookingRepository = bookingRepository;
			_eventRepository = eventRepository;
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				if(BookingsController.IsUnauthorized(reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				return Ok(await _allocationRepository.GetByBookingAsync(booking));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting allocation for the booking with reference {reference}.");
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

				return this.OkNoCache(await _allocationRepository.GetListAsync(evnt));
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the overview.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Update(string reference, List<BookingAllocation> allocation)
		{
			try
			{
				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				await _allocationRepository.UpdateAsync(booking, allocation);
				await _bookingRepository.UpdateTotalPriceAsync(booking);
				_log.Info("Updated allocation for booking {0}.", booking.Reference);
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while setting allocation for the booking with reference {reference}.");
				throw;
			}
		}
	}
}
