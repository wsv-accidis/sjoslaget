using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class DayBookingType
	{
		public Guid Id { get; set; }
		public string Title { get; set; }
		public bool IsMember { get; set; }
		public decimal Price { get; set; }
	}
}
