using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Web;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class EventController : ApiController
	{
		readonly EventRepository _eventRepository;

		public EventController(EventRepository eventRepository)
		{
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			return this.OkNoCache(evnt);

			// TODO When this goes live, should have longer cache
			// return this.OkCacheControl(evnt, WebConfig.StaticDataMaxAge);
		}
	}
}
