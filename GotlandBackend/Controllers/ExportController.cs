using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using NLog;
using Simplexcel;
using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Results;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class ExportController : ApiController
	{
		const string BookingsFilenameFormat = "AbsolutGotland_{0:yyyyMMdd_HHmmss}.xlsx";
		const string DayBookingsFilenameFormat = "AbsolutGotland_Dagbiljetter_{0:yyyyMMdd_HHmmss}.xlsx";

		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(ExportController));

		public ExportController(EventRepository eventRepository)
		{
			_eventRepository = eventRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Bookings()
		{
			var evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt) return NotFound();

			try
			{
				var exportToExcel = new ExportToExcelGenerator();
				var workbook = await exportToExcel.ExportBookingsToWorkbookAsync(evnt);

				return CreateHttpResponseMessage(workbook, BookingsFilenameFormat);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while exporting bookings.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> DayBookings()
		{
			var evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt) return NotFound();

			try
			{
				var exportToExcel = new ExportToExcelGenerator();
				var workbook = await exportToExcel.ExportDayBookingsToWorkbookAsync(evnt);

				return CreateHttpResponseMessage(workbook, DayBookingsFilenameFormat);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while exporting day bookings.");
				throw;
			}
		}

		ResponseMessageResult CreateHttpResponseMessage(Workbook workbook, string filenameFormat)
		{
			var buffer = new MemoryStream();
			workbook.Save(buffer);

			var content = new StreamContent(buffer);
			content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
			content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
			{
				FileName = string.Format(filenameFormat, DateTime.Now)
			};

			var result = new HttpResponseMessage(HttpStatusCode.OK) { Content = content };
			// This is necessary so that the front-end can read the filename of the attachment
			result.Headers.Add("Access-Control-Expose-Headers", "Content-Disposition");
			result.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };
			return ResponseMessage(result);
		}
	}
}