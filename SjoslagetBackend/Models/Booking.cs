using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Booking
	{
		public Guid Id { get; set; }

		public Guid CruiseId { get; set; }

		public string Reference { get; set; }
	}
}
