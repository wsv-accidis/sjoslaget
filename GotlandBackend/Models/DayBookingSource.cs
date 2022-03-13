using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class DayBookingSource : SoloBookingSource
	{
		public string Reference { get; set; }

		public Guid TypeId { get; set; }

		public bool PaymentConfirmed { get; set; }
	}
}
