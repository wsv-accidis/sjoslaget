using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidateResponse
	{
		public BookingCandidateResponse(Guid candidateId, int queueSize, Event evnt)
		{
			long countdown = -1;
			if(evnt.Opening.HasValue)
				countdown = Math.Max(0, Convert.ToInt64((evnt.Opening.Value - DateTime.Now).TotalMilliseconds));

			Id = candidateId;
			QueueSize = queueSize;
			Countdown = countdown;
		}

		public Guid Id { get; }

		public int QueueSize { get; }

		public long Countdown { get; }
	}
}
