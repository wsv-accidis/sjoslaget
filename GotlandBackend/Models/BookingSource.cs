using System;
using System.Collections.Generic;
using System.Linq;
using Accidis.WebServices.Models;

namespace Accidis.Gotland.WebService.Models
{
	public class BookingSource
	{
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public string SpecialRequests { get; set; }
		public List<PaxSource> Pax { get; set; }

		public static void Validate(BookingSource bookingSource, IEnumerable<Trip> trips)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidateDetails();
			bookingSource.ValidatePax(trips);
		}

		public void ValidateDetails()
		{
			if(string.IsNullOrWhiteSpace(FirstName))
				throw new BookingException("First name must be set.");
			if(string.IsNullOrWhiteSpace(LastName))
				throw new BookingException("Last name must be set.");
			if(string.IsNullOrWhiteSpace(Email))
				throw new BookingException("E-mail must be set.");
			if(string.IsNullOrWhiteSpace(PhoneNo))
				throw new BookingException("Phone number must be set.");
			if(string.IsNullOrWhiteSpace(TeamName))
				throw new BookingException("Team name must be set.");
		}

		public static void ValidatePax(BookingSource bookingSource, IEnumerable<Trip> trips)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidatePax(trips);
		}

		public void ValidatePax(IEnumerable<Trip> trips)
		{
			if(null == Pax)
				return;

			foreach(PaxSource pax in Pax)
			{
				pax.ValidateDetailsAndSetDefaults();
				pax.ValidateTrips(trips.ToDictionary(t => t.Id));
				pax.ValidateCabinClasses();
			}
		}

		public sealed class PaxSource
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string Gender { get; set; }
			public string Dob { get; set; }
			public string Nationality { get; set; }
			public Guid OutboundTripId { get; set; }
			public Guid InboundTripId { get; set; }
			public bool IsStudent { get; set; }
			public int CabinClassMin { get; set; }
			public int CabinClassPreferred { get; set; }
			public int CabinClassMax { get; set; }
			public string SpecialFood { get; set; }

			internal void ValidateCabinClasses()
			{
				if(CabinClassMin > CabinClassMax)
					throw new BookingException("Minimum cabin class must be less than or equal to maximum.");
				if(CabinClassPreferred < CabinClassMin || CabinClassPreferred > CabinClassMax)
					throw new BookingException("Preferred cabin class must be within the minimum-maximum range.");
			}

			internal void ValidateDetailsAndSetDefaults()
			{
				if(String.IsNullOrWhiteSpace(FirstName))
					throw new BookingException("First name must be set.");
				if(String.IsNullOrWhiteSpace(LastName))
					throw new BookingException("Last name must be set.");
				if(!DateOfBirth.IsValid(Dob))
					throw new BookingException("Date of birth must be set and a valid date.");
				if(!IsoNationality.TryValidateOrSetDefault(Nationality, out var nationality))
					throw new BookingException("Nationality must be a 2-letter ISO country code.");
				Nationality = nationality;
			}

			internal void ValidateTrips(Dictionary<Guid, Trip> trips)
			{
				if(!trips.TryGetValue(OutboundTripId, out Trip outTrip))
					throw new BookingException("Outbound trip does not exist.");
				if(outTrip.IsInbound)
					throw new BookingException("Outbound trip refers to an inbound trip.");

				if(!trips.TryGetValue(InboundTripId, out Trip inTrip))
					throw new BookingException("Inbound trip does not exist");
				if(!inTrip.IsInbound)
					throw new BookingException("Inbound trip refers to an outbound trip.");
			}
		}
	}
}
