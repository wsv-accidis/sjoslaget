using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Models;
using Accidis.Gotland.WebService.Services;
using NLog;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class QueueController : ApiController
	{
		readonly BookingCandidateRepository _candidateRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(QueueController).Name);

		public QueueController(BookingCandidateRepository candidateRepository)
		{
			_candidateRepository = candidateRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> Create(BookingCandidate candidate)
		{
			try
			{
				Guid id = await _candidateRepository.CreateAsync(candidate);
				int queueSize = await _candidateRepository.GetNumberOfActiveAsync();

				return Ok(new {Id = id, QueueSize = queueSize});
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating the booking candidate.");
				// TODO Differentiate between validation exceptions and others
				return BadRequest();
			}
		}

		[HttpPut]
		public async Task<IHttpActionResult> Go(string c)
		{
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

		[HttpPut]
		public async Task<IHttpActionResult> Ping(string c)
		{
			try
			{
				Guid candidateId = ParseGuid(c);
				if(await _candidateRepository.KeepAliveAsync(candidateId))
					return Ok();

				// Candidate had timed out
				return NotFound();
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
				await _candidateRepository.ResetQueueAsync();
				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while resetting the queue.");
				throw;
			}
		}

		static Guid ParseGuid(string c) => Guid.ParseExact(c, "D");
	}
}
