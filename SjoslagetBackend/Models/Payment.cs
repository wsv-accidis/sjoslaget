using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Payment
	{
		public Guid Id { get; set; }
		public Guid BookingId { get; set; }
		public decimal Amount { get; set; }
		public DateTime Created { get; set; }
	}
}
