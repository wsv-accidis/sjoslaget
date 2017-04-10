using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);

		public BookingsController(BookingRepository bookingRepository, CruiseRepository cruiseRepository)
		{
			_bookingRepository = bookingRepository;
			_cruiseRepository = cruiseRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> CreateOrUpdate(BookingSource bookingSource)
		{
			try
			{
				Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
				if(null == activeCruise)
					return NotFound();

				if(!String.IsNullOrEmpty(bookingSource.Reference))
				{
					if(!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, bookingSource.Reference, StringComparison.InvariantCultureIgnoreCase))
						return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to update.");

					BookingResult result = await _bookingRepository.UpdateAsync(activeCruise.Id, bookingSource);
					_log.Info("Updated booking {0}.", result.Reference);
					return Ok(result);
				}
				else
				{
					BookingResult result = await _bookingRepository.CreateAsync(activeCruise.Id, bookingSource);
					_log.Info("Created booking {0}.", result.Reference);
					return Ok(result);
				}
			}
			catch(AvailabilityException ex)
			{
				_log.Info(ex, "Lack of availability prevented a booking from being created.");
				return Conflict();
			}
			catch(BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while creating the booking.");
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating the booking.");
				throw;
			}
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				if(!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, reference, StringComparison.InvariantCultureIgnoreCase))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
				if(!AuthContext.IsAdmin && !booking.CruiseId.Equals(activeCruise?.Id))
					return BadRequest("Request is unauthorized, or booking belongs to an inactive cruise.");

				BookingCabinWithPax[] cabins = await _bookingRepository.GetCabinsForBookingAsync(booking);
				return Ok(BookingSource.FromBooking(booking, cabins));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}
	}
}
