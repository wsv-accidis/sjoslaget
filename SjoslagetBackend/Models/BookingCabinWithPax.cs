using System.Collections.Generic;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingCabinWithPax : BookingCabin
	{
		public BookingCabinWithPax()
		{
			Pax = new List<BookingPax>();
		}

		public List<BookingPax> Pax { get; }
	}
}
