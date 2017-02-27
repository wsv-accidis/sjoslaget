using System;
using System.Collections.Generic;
using System.Linq;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingSource
	{
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public List<Cabin> Cabins { get; set; }

		public static void Validate(BookingSource bookingSource)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");
			bookingSource.Validate();
		}

		public void Validate()
		{
			if(string.IsNullOrWhiteSpace(FirstName) || string.IsNullOrWhiteSpace(LastName) || string.IsNullOrWhiteSpace(Email) || string.IsNullOrWhiteSpace(PhoneNo))
				throw new ArgumentException("One or more required values is missing from the booking.");
			if(null == Cabins || !Cabins.Any())
				throw new ArgumentException("List of cabins is empty.");
			foreach(Cabin cabin in Cabins)
				cabin.Validate();
		}

		public sealed class Cabin
		{
			public Guid TypeId { get; set; }
			public List<Pax> Pax { get; set; }

			public void Validate()
			{
				if(Guid.Empty.Equals(TypeId))
					throw new ArgumentException("Cabin type is not specified.");
				if(null == Pax || !Pax.Any())
					throw new ArgumentException("List of pax is empty.");
				foreach(Pax pax in Pax)
					pax.Validate();
			}
		}

		public sealed class Pax
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }

			public void Validate()
			{
				if(string.IsNullOrWhiteSpace(FirstName) || string.IsNullOrWhiteSpace(LastName))
					throw new ArgumentException();
			}
		}
	}
}
