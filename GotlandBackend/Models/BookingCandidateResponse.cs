using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidateResponse
	{
		public BookingCandidateResponse(Guid candidateId, int queueSize, Event evnt)
		{
			int countdown = -1;
			if(evnt.Opening.HasValue)
				countdown = Math.Max(0, Convert.ToInt32((evnt.Opening.Value - DateTime.Now).TotalMilliseconds));

			Id = candidateId;
			QueueSize = queueSize;
			Countdown = countdown;
		}

		public Guid Id { get; }

		public int QueueSize { get; }

		public int Countdown { get; }
	}
}
