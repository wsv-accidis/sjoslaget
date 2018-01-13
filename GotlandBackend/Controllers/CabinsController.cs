using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Web;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		readonly CabinRepository _cabinRepository;
		readonly EventRepository _eventRepository;

		public CabinsController(CabinRepository cabinRepository, EventRepository eventRepository)
		{
			_cabinRepository = cabinRepository;
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Classes()
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if (null == evnt)
				return NotFound();

			return this.OkCacheControl(await _cabinRepository.GetClassesByEventAsync(evnt), WebConfig.StaticDataMaxAge);
		}
	}
}
