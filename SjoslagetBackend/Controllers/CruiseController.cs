﻿using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class CruiseController : ApiController
	{
		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(CruiseController));

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

			return this.OkCacheControl(cruise, WebConfig.StaticDataMaxAge);
		}

		[HttpGet]
		public async Task<IHttpActionResult> ActiveSubs()
		{
			Cruise cruise = await _cruiseRepository.GetActiveAsync();
			if (null == cruise)
				return NotFound();

			SubCruise[] subCruises = await _cruiseRepository.GetSubCruisesAsync(cruise);
			return this.OkCacheControl(subCruises, WebConfig.StaticDataMaxAge);
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
