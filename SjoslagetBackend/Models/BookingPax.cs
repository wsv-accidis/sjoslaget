using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingPax
	{
		public Guid Id { get; set; }
		public Guid BookingCabinId { get; set; }
		public string Group { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public Gender Gender { get; set; }
		public DateOfBirth Dob { get; set; }
		public string Nationality { get; set; }
		public int Years { get; set; }

		public static BookingPax FromSource(BookingSource.Pax source, Guid bookingCabinId)
		{
			return new BookingPax
			{
				BookingCabinId = bookingCabinId,
				Group = source.Group,
				FirstName = source.FirstName,
				LastName = source.LastName,
				Gender = GenderConvert.FromString(source.Gender),
				Dob = new DateOfBirth(source.Dob),
				Nationality = source.Nationality,
				Years = source.Years
			};
		}
	}
}
