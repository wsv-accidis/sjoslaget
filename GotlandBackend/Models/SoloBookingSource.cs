using System;
using Accidis.WebServices.Models;

namespace Accidis.Gotland.WebService.Models
{
	public class SoloBookingSource
	{
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string GroupName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string Gender { get; set; }
		public string Dob { get; set; }
		public string Food { get; set; }

		public static void Validate(SoloBookingSource source)
		{
			if(null == source)
				throw new ArgumentNullException(nameof(source), "Booking data not present");

			source.Validate();
		}

		void Validate()
		{
			if(string.IsNullOrWhiteSpace(FirstName))
				throw new BookingException("First name must be set.");
			if(string.IsNullOrWhiteSpace(LastName))
				throw new BookingException("Last name must be set.");
			if(string.IsNullOrWhiteSpace(Email))
				throw new BookingException("E-mail must be set.");
			if(string.IsNullOrWhiteSpace(PhoneNo))
				throw new BookingException("Phone number must be set.");
			if(!DateOfBirth.IsValid(Dob))
				throw new BookingException("Date of birth must be set and a valid date.");
			if(String.IsNullOrEmpty(Food))
				throw new BookingException("Food must be set.");
		}
	}
}
