using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public class BookingCabin
	{
		public Guid Id { get; set; }
		public Guid BookingId { get; set; }
		public Guid CabinTypeId { get; set; }

		public static BookingCabin FromSource(BookingSource.Cabin source, Guid bookingId)
		{
			return new BookingCabin
			{
				BookingId = bookingId,
				CabinTypeId = source.TypeId
			};
		}
	}
}
