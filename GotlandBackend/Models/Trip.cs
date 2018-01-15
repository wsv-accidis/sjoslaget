using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class Trip
	{
		public Guid Id { get; set; }
		public string Name { get; set; }
		public bool IsInbound { get; set; }
		public DateTime? Departure { get; set; }
		public decimal Price { get; set; }
	}
}
