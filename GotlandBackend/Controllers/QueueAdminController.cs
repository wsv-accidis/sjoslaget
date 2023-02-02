using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;
using System;
using System.Threading.Tasks;
using System.Web.Http;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class QueueAdminController : ApiController
	{
		readonly BookingCandidateRepository _candidateRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(QueueAdminController));

		public QueueAdminController(BookingCandidateRepository candidateRepository, EventRepository eventRepository)
		{
			_candidateRepository = candidateRepository;
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Countdown()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				return this.OkNoCache(new EventCountdown
				{
					Opening = evnt.Opening,
					Countdown = Math.Max(0, IntervalCalculator.CalculateInterval(DateTime.Now, evnt.Opening))
				});
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the countdown.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Dashboard()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				QueueDashboardItem[] items = await _candidateRepository.GetQueueAsync(evnt.Opening);
				return this.OkNoCache(items);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting the queue.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Reset()
		{
			try
			{
				await _candidateRepository.DeleteAllAsync();
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while resetting the queue.");
				throw;
			}
		}
	}
}
