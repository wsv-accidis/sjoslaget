using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Db;
using Accidis.WebServices.Exceptions;
using Accidis.WebServices.Models;
using Accidis.WebServices.Web;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class QueueController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly BookingCandidateRepository _candidateRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(nameof(QueueController));

		public QueueController(BookingRepository bookingRepository, BookingCandidateRepository candidateRepository, EventRepository eventRepository)
		{
			_bookingRepository = bookingRepository;
			_candidateRepository = candidateRepository;
			_eventRepository = eventRepository;
		}

		[HttpPut]
		public async Task<IHttpActionResult> Claim(string c)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				if(!evnt.IsOpenAndNotLocked)
				{
					_log.Warn("An attempt was made to enqueue a candidate before the event is open.");
					return BadRequest();
				}

				var candidateId = ParseGuid(c);
				var placeInQueue = await _candidateRepository.EnqueueAsync(candidateId);
				return Ok(new { PlaceInQueue = placeInQueue });
			}
			catch(FormatException)
			{
				return BadRequest();
			}
			catch(NotFoundException)
			{
				_log.Warn("An attempt was made to enqueue a candidate that does not exist.");
				return NotFound();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while enqueueing the candidate.");
				throw;
			}
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(BookingCandidate candidate)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var id = await _candidateRepository.CreateAsync(candidate);
				var queueSize = await _candidateRepository.GetNumberOfActiveAsync();

				return Ok(new BookingCandidateResponse(id, queueSize, evnt));
			}
			catch(BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while creating the booking candidate.");
				return BadRequest();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating the booking candidate.");
				throw;
			}
		}

		[HttpPut]
		public async Task<IHttpActionResult> Ping(string c)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				var candidateId = ParseGuid(c);
				if(!await _candidateRepository.KeepAliveAsync(candidateId))
					return NotFound();

				var queueSize = await _candidateRepository.GetNumberOfActiveAsync();
				return Ok(new BookingCandidateResponse(candidateId, queueSize, evnt));
			}
			catch(FormatException)
			{
				return BadRequest();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while keeping a candidate alive.");
				throw;
			}
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Stats(string reference)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();

				if(BookingsController.IsUnauthorized(reference))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				var bookingQueueStats = await _bookingRepository.GetQueueStatsByReferenceAsync(reference, evnt.Opening);
				if(null == bookingQueueStats)
					return Ok(new BookingQueueStats());

				return this.OkCacheControl(bookingQueueStats, WebConfig.StaticDataMaxAge);
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[HttpPost]
		public async Task<IHttpActionResult> ToBooking(string c)
		{
			try
			{
				var evnt = await _eventRepository.GetActiveAsync();
				if(null == evnt)
					return NotFound();
				if(evnt.IsLocked)
					return BadRequest("The event is locked and can no longer accept bookings.");

				var candidateId = ParseGuid(c);
				BookingCandidate candidate;
				int placeInQueue;

				using(var db = DbUtil.Open())
				{
					candidate = await _candidateRepository.FindByIdAsync(db, candidateId);
					if(null == candidate)
						return NotFound();

					placeInQueue = await _candidateRepository.FindPlaceInQueueAsync(db, candidateId);
					if(0 == placeInQueue)
					{
						_log.Warn($"An attempt was made to create a booking for candidate ID = {candidateId} with no place in the queue.");
						return NotFound();
					}
				}

				var result = await _bookingRepository.CreateFromCandidateAsync(evnt, candidate, placeInQueue);
				_log.Info("Created booking {0} from candidate {1} at position {2}.", result.Reference, candidate.Id,
					placeInQueue);

				await SendBookingCreatedMailAsync(evnt, candidate, result);
				return Ok(result);
			}
			catch(BookingCandidateReusedException ex)
			{
				// If a booking already exists with this candidate, return it instead of failing the request.
				// This allows recovery from the failure state where the 
				return Ok(new BookingResult { Reference = ex.ExistingReference });
			}
			catch(BookingException)
			{
				return BadRequest();
			}
			catch(FormatException)
			{
				return BadRequest();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating a booking.");
				throw;
			}
		}

		static Guid ParseGuid(string c)
		{
			if(string.IsNullOrEmpty(c))
				throw new FormatException("Guid can't be an empty or blank string.");

			return Guid.ParseExact(c, "D");
		}

		async Task SendBookingCreatedMailAsync(Event evnt, BookingCandidate candidate, BookingResult result)
		{
			try
			{
				using(var emailSender = new EmailSender()) 
					await emailSender.SendBookingCreatedMailAsync(evnt.Name, candidate.Email, result.Reference, result.Password);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on created booking.");
			}
		}
	}
}