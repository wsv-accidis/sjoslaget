using System;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Results;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Simplexcel;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class ExportController : ApiController
	{
		const string UpdatedSinceFormat = "yyyyMMdd";
		const string FilenameFormat = "Export_{0:yyyyMMdd_HHmmss}.xlsx";

		readonly CabinRepository _cabinRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly ProductRepository _productRepository;

		public ExportController(CabinRepository cabinRepository, CruiseRepository cruiseRepository, ProductRepository productRepository)
		{
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
			_productRepository = productRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Excel(bool onlyFullyPaid = false, string updatedSince = null)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			DateTime? updatedSinceDate = String.IsNullOrEmpty(updatedSince)
				? null
				: new DateTime?(DateTime.ParseExact(updatedSince, UpdatedSinceFormat, CultureInfo.InvariantCulture));

			var exportToExcelGenerator = new ExportToExcelGenerator(_cabinRepository, _productRepository);
			Workbook workbook = await exportToExcelGenerator.ExportToWorkbook(activeCruise, onlyFullyPaid, updatedSinceDate);

			return CreateHttpResponseMessage(workbook);
		}

		ResponseMessageResult CreateHttpResponseMessage(Workbook workbook)
		{
			var buffer = new MemoryStream();
			workbook.Save(buffer);

			var content = new StreamContent(buffer);
			content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
			content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
			{
				FileName = String.Format(FilenameFormat, DateTime.Now)
			};

			var result = new HttpResponseMessage(HttpStatusCode.OK) {Content = content};
			// This is necessary so that the front-end can read the filename of the attachment
			result.Headers.Add("Access-Control-Expose-Headers", "Content-Disposition");
			result.Headers.CacheControl = new CacheControlHeaderValue {NoCache = true};
			return ResponseMessage(result);
		}
	}
}
