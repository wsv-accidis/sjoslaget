﻿namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseCabinWithType : CabinType
	{
		public int Count { get; set; }
		public decimal PricePerPax { get; set; }
	}
}
