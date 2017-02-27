using System;
using System.Threading.Tasks;
using System.Web.Http;
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
		public async Task<IHttpActionResult> Create(BookingSource bookingSource)
		{
			Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			try
			{
				BookingSource.Validate(bookingSource);
			}
			catch(ArgumentException ex)
			{
				return BadRequest(ex.Message);
			}

			var result = await _bookingRepository.CreateAsync(activeCruise, bookingSource);

			_log.Info("Created booking {0}.", result.Reference);
			return Ok(result);
		}
	}
}
