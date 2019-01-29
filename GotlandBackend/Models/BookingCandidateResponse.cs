using Accidis.Gotland.WebService.Services;
using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidateResponse
	{
		public BookingCandidateResponse(Guid candidateId, int queueSize, Event evnt)
		{
			Id = candidateId;
			QueueSize = queueSize;
			Countdown = Math.Max(0, IntervalCalculator.CalculateInterval(DateTime.Now, evnt.Opening));
		}

		public Guid Id { get; }

		public int QueueSize { get; }

		public long Countdown { get; }
	}
}
