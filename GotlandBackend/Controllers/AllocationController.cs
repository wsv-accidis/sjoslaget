using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class AllocationController : ApiController
	{
		readonly AllocationRepository _allocationRepository;
		readonly BookingRepository _bookingRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(AllocationController).Name);

		public AllocationController(AllocationRepository allocationRepository, BookingRepository bookingRepository)
		{
			_allocationRepository = allocationRepository;
			_bookingRepository = bookingRepository;
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
		[HttpPost]
		public async Task<IHttpActionResult> Update(string reference, List<BookingAllocation> allocation)
		{
			try
			{
				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				await _allocationRepository.UpdateAsync(booking, allocation);
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
