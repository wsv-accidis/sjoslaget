using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Web;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class TripsController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly TripRepository _tripRepository;

		public TripsController(EventRepository eventRepository, TripRepository tripRepository)
		{
			_eventRepository = eventRepository;
			_tripRepository = tripRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Inbound()
		{
			return await GetTripsByDirection(true);
		}

		[HttpGet]
		public async Task<IHttpActionResult> Outbound()
		{
			return await GetTripsByDirection(false);
		}

		async Task<IHttpActionResult> GetTripsByDirection(bool getInbound)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			Trip[] trips = await _tripRepository.GetByDirectionAndEventAsync(evnt, getInbound);
			return this.OkCacheControl(trips, WebConfig.StaticDataMaxAge);
		}
	}
}
