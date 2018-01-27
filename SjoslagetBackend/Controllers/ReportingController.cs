using System;
using System.Threading.Tasks;
using System.Web.Hosting;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
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
		public async Task<IHttpActionResult> Active()
		{
			var cruise = await _cruiseRepository.GetActiveAsync();
			if (null == cruise)
				return NotFound();

			return this.OkCacheControl(await _reportRepository.GetActiveAsync(cruise), WebConfig.DynamicDataMaxAge);
		}

		// This is a GET so we can trigger it from a scheduled monitoring task
		[HttpGet]
		public IHttpActionResult Update()
		{
			HostingEnvironment.QueueBackgroundWorkItem(ct => _reportingService.GenerateReportsAsync());
			return this.OkNoCache(String.Empty);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Summary()
		{
			var cruise = await _cruiseRepository.GetActiveAsync();
			if (null == cruise)
				return NotFound();

			Report[] reports = await _reportRepository.GetActiveAsync(cruise);
			return this.OkCacheControl(ReportSummary.FromReports(reports), WebConfig.DynamicDataMaxAge);
		}
	}
}
