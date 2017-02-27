using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseCabinSource
	{
		public Guid TypeId { get; set; }
		public int Count { get; set; }
		public decimal PricePerPax { get; set; }
	}
}