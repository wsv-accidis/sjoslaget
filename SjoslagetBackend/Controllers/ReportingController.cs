using System;
using System.Web.Hosting;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Services;
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

		// This is a GET so we can trigger it from a scheduled monitoring task
		[HttpGet]
		public IHttpActionResult Update()
		{
			HostingEnvironment.QueueBackgroundWorkItem(ct => _reportingService.GenerateReportsAsync());
			return this.OkNoCache(String.Empty);
		}
	}
}
