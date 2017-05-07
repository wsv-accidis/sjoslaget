using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class CruiseController : ApiController
	{
		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(CruiseController).Name);

		public CruiseController(CruiseRepository cruiseRepository)
		{
			_cruiseRepository = cruiseRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			Cruise cruise = await _cruiseRepository.GetActiveAsync();
			if(null == cruise)
				return NotFound();

			return Ok(cruise);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Lock()
		{
			Cruise cruise = await _cruiseRepository.GetActiveAsync();
			if(null == cruise)
				return NotFound();

			try
			{
				cruise.IsLocked = !cruise.IsLocked;
				await _cruiseRepository.UpdateMetadataAsync(cruise);

				return Ok(IsLockedResult.FromCruise(cruise));
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while locking/unlocking the active cruise.");
				throw;
			}
		}
	}
}
