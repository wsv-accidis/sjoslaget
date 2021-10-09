using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Web;
using Dapper;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class PrinterController : ApiController
	{
		const int PrinterQueueMaxLength = 20;
		static readonly TimeSpan PrinterQueueTimeout = new TimeSpan(0, 1, 0);

		// Since this controller doesn't need to persist data for more than a few seconds at most we do everything inmem.
		// ReSharper disable once InconsistentNaming
		static readonly List<BookingLabel> _printerQueue = new List<BookingLabel>();
		static DateTime? _lastPoll;

		readonly BookingRepository _bookingRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(PrinterController));

		public PrinterController(BookingRepository bookingRepository)
		{
			_bookingRepository = bookingRepository;
		}

		bool PrinterHasTimedOut => !_lastPoll.HasValue || DateTime.UtcNow - _lastPoll.Value > PrinterQueueTimeout;

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Enqueue(string reference)
		{
			BookingLabel label;
			try
			{
				label = await CreateLabel(reference);
				if(null == label)
					return NotFound();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating a label.");
				throw;
			}

			lock(_printerQueue)
			{
				CleanupPrinterQueue();
				if(_printerQueue.Count >= PrinterQueueMaxLength || PrinterHasTimedOut)
					return Conflict();

				if(!_printerQueue.Any(b => b.Id.Equals(label.Id)))
					_printerQueue.Add(label);
			}

			return Ok();
		}

		[HttpGet]
		[Authorize(Roles = Roles.Admin)]
		public IHttpActionResult IsAvailable()
		{
			return this.OkNoCache(!PrinterHasTimedOut);
		}

		[HttpPut]
		[Authorize(Roles = Roles.Admin)]
		public IHttpActionResult Poll()
		{
			_lastPoll = DateTime.UtcNow;
			CleanupPrinterQueue();

			BookingLabel[] printerQueue;
			lock(_printerQueue)
			{
				printerQueue = _printerQueue.ToArray();
				_printerQueue.Clear();
			}

			// Technically not needed since we use PUT (request has side-effects so GET would be inappropriate)
			return this.OkNoCache(printerQueue);
		}

		void CleanupPrinterQueue()
		{
			lock(_printerQueue)
			{
				// Throw away stale items in the printer queue
				if(PrinterHasTimedOut)
					_printerQueue.Clear();

				// If the queue is getting too long, remove old items until it's not
				while(_printerQueue.Count > PrinterQueueMaxLength)
					_printerQueue.RemoveAt(0);
			}
		}

		async Task<BookingLabel> CreateLabel(string reference)
		{
			using(var db = DbUtil.Open())
			{
				Booking booking = await _bookingRepository.FindByReferenceAsync(db, reference);
				if(null == booking)
					return null;

				var label = new BookingLabel
				{
					Id = booking.Id,
					Reference = booking.Reference,
					FullName = string.Concat(booking.FirstName, ' ', booking.LastName),
					SubCruise = booking.SubCruise.ToString()
				};

				var cabinsQuery = await db.QueryAsync<NameCountPair>("select CT.[Name], COUNT(*) [Count] " +
																	 "from [BookingCabin] BC " +
																	 "left join [CabinType] CT on BC.[CabinTypeId] = CT.[Id] " +
																	 "where BC.[BookingId] = @Id " +
																	 "group by CT.[Name], CT.[Order] " +
																	 "order by CT.[Order]",
					new { Id = booking.Id });
				label.Cabins = cabinsQuery.ToArray();

				var productsQuery = await db.QueryAsync<NameCountPair>("select PT.[Name], BP.[Quantity] [Count] " +
																	   "from [BookingProduct] BP " +
																	   "left join [ProductType] PT on BP.[ProductTypeId] = PT.[Id] " +
																	   "where BP.[BookingId] = @Id " +
																	   "order by PT.[Order]",
					new { Id = booking.Id });
				label.Products = productsQuery.ToArray();

				return label;
			}
		}

		// ReSharper disable ClassNeverInstantiated.Local, UnusedAutoPropertyAccessor.Local, UnusedMember.Local
		sealed class BookingLabel
		{
			public Guid Id { get; set; }
			public string Reference { get; set; }
			public string FullName { get; set; }
			public string SubCruise { get; set; }
			public NameCountPair[] Cabins { get; set; }
			public NameCountPair[] Products { get; set; }
		}

		sealed class NameCountPair
		{
			public string Name { get; set; }
			public int Count { get; set; }
		}
		// ReSharper enable ClassNeverInstantiated.Local, UnusedAutoPropertyAccessor.Local, UnusedMember.Local
	}
}
