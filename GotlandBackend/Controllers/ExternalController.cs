using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class ExternalController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly ExternalBookingRepository _externalBookingRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(ExternalController).Name);

		public ExternalController(EventRepository eventRepository, ExternalBookingRepository externalBookingRepository)
		{
			_eventRepository = eventRepository;
			_externalBookingRepository = externalBookingRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(ExternalBookingSource booking)
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				Guid id = await _externalBookingRepository.CreateAsync(evnt, booking);
				_log.Info("Created external booking with ID {0}.", id);

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating an external booking.");
				throw;
			}
		}
	}
}
