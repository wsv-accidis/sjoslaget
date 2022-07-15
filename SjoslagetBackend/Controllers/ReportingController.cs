﻿using System;
using System.Threading.Tasks;
using System.Web.Hosting;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Web;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class ReportingController : ApiController
	{
		readonly CruiseRepository _cruiseRepository;
		readonly ReportingService _reportingService;
		readonly ReportRepository _reportRepository;

		public ReportingController(CruiseRepository cruiseRepository, ReportingService reportingService, ReportRepository reportRepository)
		{
			_cruiseRepository = cruiseRepository;
			_reportingService = reportingService;
			_reportRepository = reportRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Current()
		{
			var cruise = await _cruiseRepository.GetActiveAsync();
			if(null == cruise)
				return NotFound();

			using(var db = DbUtil.Open())
			{
				return this.OkCacheControl(new
					{
						// TODO
						AgeDistribution = await _reportingService.GetAgeDistribution(db, cruise, SubCruiseCode.None),
						BookingsByPayment = await _reportingService.GetNumberOfBookingsByPaymentStatus(db, cruise),
						Genders = await _reportingService.GetGenders(db, cruise, SubCruiseCode.None),
						TopContacts = await _reportingService.GetTopContacts(db, cruise, SubCruiseCode.None, 15),
						TopGroups = await _reportingService.GetTopGroups(db, cruise, SubCruiseCode.None, 15)
					},
					WebConfig.DynamicDataMaxAge);
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Summary()
		{
			var cruise = await _cruiseRepository.GetActiveAsync();
			if(null == cruise)
				return NotFound();

			// TODO
			Report[] reports = await _reportRepository.GetActiveAsync(cruise, SubCruiseCode.None);
			return this.OkCacheControl(ReportSummary.FromReports(reports), WebConfig.DynamicDataMaxAge);
		}

		// This is a GET so we can trigger it from a scheduled monitoring task
		// We also generate reports from BookingsController
		[HttpGet]
		public IHttpActionResult Update()
		{
			HostingEnvironment.QueueBackgroundWorkItem(ct => _reportingService.GenerateReportsAsync());
			return this.OkNoCache(String.Empty);
		}
	}
}
