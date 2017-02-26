using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);
		readonly BookingRepository _repository;

		public BookingsController(BookingRepository bookingRepository)
		{
			_repository = bookingRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create()
		{
			Cruise activeCruise;
			using(var db = SjoslagetDb.Open())
				activeCruise = Cruise.Active(db);

			if(null == activeCruise)
				return NotFound();

			var result = await _repository.CreateAsync(activeCruise);

			_log.Info("Created booking {0}.", result.Reference);
			return Ok(result);
		}
	}
}
