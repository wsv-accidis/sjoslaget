using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		readonly CabinRepository _cabinRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(CabinsController).Name);

		public CabinsController(CabinRepository cabinRepository, EventRepository eventRepository)
		{
			_cabinRepository = cabinRepository;
			_eventRepository = eventRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				CabinClass[] cabinClasses = await _cabinRepository.GetClassesByEventAsync(evnt);
				return this.OkCacheControl(cabinClasses, WebConfig.StaticDataMaxAge);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting cabin classes.");
				throw;
			}
		}

		[HttpGet]
		public async Task<IHttpActionResult> Capacity()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				CabinCapacity[] cabinCapacity = await _cabinRepository.GetCapacityByEventAsync(evnt);
				return this.OkCacheControl(cabinCapacity, WebConfig.StaticDataMaxAge);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting cabin capacity.");
				throw;
			}
		}

		[HttpGet]
		[Authorize(Roles = Roles.Admin)]
		public async Task<IHttpActionResult> ClaimedCapacity()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				ClaimedCapacity[] claimedCapacity = await _cabinRepository.GetClaimedCapacityByEventAsync(evnt);
				return this.OkNoCache(claimedCapacity);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting claimed capacity.");
				throw;
			}
		}

		[HttpGet]
		[Authorize(Roles = Roles.Admin)]
		public async Task<IHttpActionResult> PaidCapacity()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				CapacityWithPaymentStatus capacity = await _cabinRepository.GetCapacityWithPaymentStatusByEventAsync(evnt);
				return this.OkNoCache(capacity);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting claimed capacity.");
				throw;
			}
		}

		[HttpGet]
		public async Task<IHttpActionResult> Details()
		{
			try
			{
				Event evnt = await _eventRepository.GetActiveAsync();
				if (null == evnt)
					return NotFound();

				CabinClassDetail[] cabinClassDetail = await _cabinRepository.GetCabinClassDetailByEventAsync(evnt);
				return this.OkCacheControl(cabinClassDetail, WebConfig.StaticDataMaxAge);
			}
			catch (Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while getting cabin details.");
				throw;
			}
		}
	}
}
