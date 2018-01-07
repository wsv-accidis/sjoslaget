using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);

		public BookingsController(EventRepository eventRepository)
		{
			_eventRepository = eventRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> Get(string reference)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				// TODO
				return InternalServerError();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}
	}
}
