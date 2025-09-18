using System;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Results;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using NLog;
using Simplexcel;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class ExportController : ApiController
	{
		const string UpdatedSinceFormat = "yyyyMMdd";
		const string FilenameFormat = "Export_{0}_{1:yyyyMMdd_HHmmss}.xlsx";

		readonly CabinRepository _cabinRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(ExportController));
		readonly ProductRepository _productRepository;

		public ExportController(CabinRepository cabinRepository, CruiseRepository cruiseRepository, ProductRepository productRepository)
		{
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
			_productRepository = productRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Excel(bool onlyFullyPaid = false, string updatedSince = null, string subCruise = null)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			var subCruiseCode = string.IsNullOrEmpty(subCruise) ? SubCruiseCode.First : SubCruiseCode.FromString(subCruise);
			var updatedSinceDate = string.IsNullOrEmpty(updatedSince)
				? null
				: new DateTime?(DateTime.ParseExact(updatedSince, UpdatedSinceFormat, CultureInfo.InvariantCulture));

			try
			{
				var exportToExcelGenerator = new ExportToExcelGenerator(_cabinRepository, _productRepository);
				var workbook = await exportToExcelGenerator.ExportToWorkbookAsync(activeCruise, onlyFullyPaid, subCruiseCode.ToString(), updatedSinceDate);
				return CreateHttpResponseMessage(workbook, subCruise);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while exporting.");
				throw;
			}
		}

		ResponseMessageResult CreateHttpResponseMessage(Workbook workbook, string subCruise)
		{
			var buffer = new MemoryStream();
			workbook.Save(buffer);

			var content = new StreamContent(buffer);
			content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
			content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
			{
				FileName = string.Format(FilenameFormat, subCruise, DateTime.Now)
			};

			var result = new HttpResponseMessage(HttpStatusCode.OK) { Content = content };
			// This is necessary so that the front-end can read the filename of the attachment
			result.Headers.Add("Access-Control-Expose-Headers", "Content-Disposition");
			result.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };
			return ResponseMessage(result);
		}
	}
}