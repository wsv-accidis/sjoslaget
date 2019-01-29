using Accidis.Gotland.WebService.Services;
using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class QueueDashboardItem
	{
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string TeamName { get; set; }
		public int TeamSize { get; set; }
		public DateTime Created { get; set; }
		public DateTime? Queued { get; set; }
		public int QueueNo { get; set; }
		public int QueueLatencyMs { get; set; }
		public string Reference { get; set; }

		public static int TryCalculateQueueLatencyMs(DateTime? eventOpening, DateTime? queueCreated)
		{
			long temp = IntervalCalculator.CalculateInterval(eventOpening, queueCreated);
			if(temp >= 0 && temp <= Int32.MaxValue)
				return (int)temp;
			return -1;
		}
	}
}
