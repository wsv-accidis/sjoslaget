using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseCabinAvailability
	{
		public Guid CabinTypeId { get; set; }

		public int Available { get; set; }
	}
}
