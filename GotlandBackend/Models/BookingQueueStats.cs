namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingQueueStats
	{
		public int TeamSize { get; set; }

		public int QueueNo { get; set; }

		public int QueueLatencyMs { get; set; }

		public int AheadInQueue { get; set; }
	}
}
