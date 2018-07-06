using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.WebServices.Auth;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class PrinterController : ApiController
	{
		readonly ConcurrentQueue<Guid> _printerQueue = new ConcurrentQueue<Guid>();

		// Since this controller doesn't need to persist data for more than a few seconds at most we do everything inmem.
		DateTime? _lastPrinterRegistration;

		[HttpGet]
		[Authorize(Roles = Roles.Admin)]
		public async Task<IHttpActionResult> Poll()
		{
			return Ok(new BookingLabel[0]);
		}

		[HttpPost]
		[Authorize(Roles = Roles.Admin)]
		public async Task<IHttpActionResult> Enqueue(string reference)
		{
			return Ok();
		}

		[HttpPost]
		[Authorize(Roles = Roles.Admin)]
		public async Task<IHttpActionResult> Dequeue(string reference)
		{
			return Ok();
		}

		sealed class BookingLabel
		{
			public string Reference { get; set; }
			public string FullName { get; set; }
			public IEnumerable<Tuple<string, int>> Cabins { get; set; }
			public IEnumerable<Tuple<string, int>> Products { get; set; }
		}
	}
}
