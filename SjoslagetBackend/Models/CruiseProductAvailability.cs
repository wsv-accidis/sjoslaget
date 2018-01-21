using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseProductAvailability
	{
		public const int NotLimited = -1;

		public int Availability => IsLimited ? Math.Max(0, Count - TotalQuantity) : NotLimited;

		public Guid ProductTypeId { get; set; }

		public bool IsLimited => Count > NotLimited;

		public int Count { get; set; }

		public int TotalQuantity { get; set; }
	}
}
