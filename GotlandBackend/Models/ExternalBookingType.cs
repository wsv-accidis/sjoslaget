using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class ExternalBookingType
	{
		public Guid Id { get; set; }
		public string Title { get; set; }
		public decimal Price { get; set; }
	}
}
