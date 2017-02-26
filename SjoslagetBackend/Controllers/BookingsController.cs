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
		public async Task<IHttpActionResult> Create()
		{
			Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			var result = await _bookingRepository.CreateAsync(activeCruise);

			_log.Info("Created booking {0}.", result.Reference);
			return Ok(result);
		}
	}
}
