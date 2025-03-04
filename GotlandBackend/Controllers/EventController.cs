using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class EventController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(EventController));

		public EventController(EventRepository eventRepository)
		{
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				return this.OkCacheControl(evnt, WebConfig.DynamicDataMaxAge);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the event.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Lock()
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				evnt.IsLocked = !evnt.IsLocked;
				await _eventRepository.UpdateMetadataAsync(evnt);
				return Ok(new { evnt.IsLocked });
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while locking/unlocking the event.");
				throw;
			}
		}
	}
}