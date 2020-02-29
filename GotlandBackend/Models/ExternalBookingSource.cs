using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class ExternalBookingSource : SoloBookingSource
	{
		public Guid TypeId { get; set; }
	}
}
