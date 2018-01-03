using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Db;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class QueueController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly BookingCandidateRepository _candidateRepository;
		readonly EventRepository _eventRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(QueueController).Name);

		public QueueController(BookingRepository bookingRepository, BookingCandidateRepository candidateRepository, EventRepository eventRepository)
		{
			_bookingRepository = bookingRepository;
			_candidateRepository = candidateRepository;
			_eventRepository = eventRepository;
		}

		[HttpPut]
		public async Task<IHttpActionResult> Claim(string c)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			if(!evnt.IsOpen)
			{
				_log.Warn("An attempt was made to enqueue a candidate before the event is open.");
				return BadRequest();
			}

			try
			{
				Guid candidateId = ParseGuid(c);
				int placeInQueue = await _candidateRepository.EnqueueAsync(candidateId);
				return Ok(new {PlaceInQueue = placeInQueue});
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
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				Guid id = await _candidateRepository.CreateAsync(candidate);
				int queueSize = await _candidateRepository.GetNumberOfActiveAsync();

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
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				Guid candidateId = ParseGuid(c);
				if(!await _candidateRepository.KeepAliveAsync(candidateId))
					return NotFound();

				int queueSize = await _candidateRepository.GetNumberOfActiveAsync();
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

		// TODO Admins only
		[HttpPost]
		public async Task<IHttpActionResult> Reset()
		{
			try
			{
				await _candidateRepository.DeleteAllAsync();
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while resetting the queue.");
				throw;
			}
		}

		[HttpPost]
		public async Task<IHttpActionResult> ToBooking(string c)
		{
			Event evnt = await _eventRepository.GetActiveAsync();
			if(null == evnt)
				return NotFound();

			try
			{
				Guid candidateId = ParseGuid(c);
				using(var db = DbUtil.Open())
				{
					BookingCandidate candidate = await _candidateRepository.FindByIdAsync(db, candidateId);
					if(null == candidate)
						return NotFound();

					int placeInQueue = await _candidateRepository.FindPlaceInQueueAsync(db, candidateId);
					if(0 == placeInQueue)
					{
						_log.Warn($"An attempt was made to create a booking for candidate ID = {candidateId} with no place in the queue.");
						return NotFound();
					}

					BookingResult result = await _bookingRepository.CreateFromCandidate(db, evnt, candidate, placeInQueue);
					_log.Info("Created booking {0} from candidate {1} at position {2}.", result.Reference, candidate.Id, placeInQueue);

					// TODO Send e-mail
					return Ok(result);
				}
			}
			catch(BookingException)
			{
				return Conflict();
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

		static Guid ParseGuid(string c) => Guid.ParseExact(c, "D");
	}
}
