using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingPax
	{
		public Guid Id { get; set; }
		public Guid BookingCabinId { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }

		public static BookingPax FromSource(BookingSource.Pax source, Guid bookingCabinId)
		{
			return new BookingPax
			{
				BookingCabinId = bookingCabinId,
				FirstName = source.FirstName,
				LastName = source.LastName
			};
		}
	}
}
