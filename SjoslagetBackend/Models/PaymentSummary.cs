using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class PaymentSummary
	{
		public decimal Total { get; set; }
		public DateTime Latest { get; set; }

		public static PaymentSummary Empty => new PaymentSummary
		{
			Total = 0.0m,
			Latest = DateTime.MinValue
		};
	}
}
