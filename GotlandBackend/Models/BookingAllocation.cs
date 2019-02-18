using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingAllocation
	{
		public Guid CabinId { get; set; }
		public int NumberOfPax { get; set; }
		public string Note { get; set; }
	}
}
