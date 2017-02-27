using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Booking
	{
		public Guid Id { get; set; }
		public Guid CruiseId { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }

		public static Booking FromSource(BookingSource source, Guid cruiseId, string reference)
		{
			return new Booking
			{
				CruiseId = cruiseId,
				Reference = reference,
				FirstName = source.FirstName,
				LastName = source.LastName,
				Email = source.Email,
				PhoneNo = source.PhoneNo
			};
		}
	}
}
