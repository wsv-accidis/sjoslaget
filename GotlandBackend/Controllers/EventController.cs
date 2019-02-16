using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class EventController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(EventController).Name);

		public EventController(EventRepository eventRepository)
		{
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				return this.OkNoCache(evnt);

				// TODO When this goes live, should have longer cache
				// return this.OkCacheControl(evnt, WebConfig.StaticDataMaxAge);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the event.");
				throw;
			}
		}
	}
}
