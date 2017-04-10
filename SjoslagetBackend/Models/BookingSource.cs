using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingSource
	{
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string Lunch { get; set; }
		public List<Cabin> Cabins { get; set; }

		public static BookingSource FromBooking(Booking booking, BookingCabinWithPax[] cabins)
		{
			return new BookingSource
			{
				Reference = booking.Reference,
				FirstName = booking.FirstName,
				LastName = booking.LastName,
				Email = booking.Email,
				PhoneNo = booking.PhoneNo,
				Lunch = booking.Lunch,
				Cabins = cabins.Select(c => new Cabin
				{
					TypeId = c.CabinTypeId,
					Pax = c.Pax.Select(p => new Pax
					{
						Group = p.Group,
						FirstName = p.FirstName,
						LastName = p.LastName,
						Dob = p.Dob.ToString(),
						Gender = p.Gender.ToString(),
						Nationality = p.Nationality.ToUpperInvariant(),
						Years = p.Years
					}).ToList()
				}).ToList()
			};
		}

		public static void Validate(BookingSource bookingSource)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidateDetails();
			bookingSource.ValidateCabins();
		}

		public static void ValidateCabins(BookingSource bookingSource)
		{
			if (null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidateCabins();
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
			if(string.IsNullOrWhiteSpace(Lunch))
				throw new BookingException("Lunch preference must be set.");
		}

		void ValidateCabins()
		{
			if(null == Cabins || !Cabins.Any())
				throw new BookingException("List of cabins must not be empty.");

			bool isFirstCabin = true;
			string defaultGroup = string.Empty;
			foreach(Cabin cabin in Cabins)
			{
				cabin.Validate(isFirstCabin, ref defaultGroup);
				isFirstCabin = false;
			}
		}

		public sealed class Cabin
		{
			public Guid TypeId { get; set; }
			public List<Pax> Pax { get; set; }

			public void Validate(bool isFirstCabin, ref string defaultGroup)
			{
				if(Guid.Empty.Equals(TypeId))
					throw new BookingException("Cabin type must be specified.");
				if(null == Pax || !Pax.Any())
					throw new BookingException("List of pax must not be empty.");

				BookingSource.Pax.ValidateAndSetDefaults(Pax, isFirstCabin, ref defaultGroup);
			}
		}

		public sealed class Pax
		{
			static string DefaultNationality = "se";

			public string Group { get; set; }
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string Gender { get; set; }
			public string Dob { get; set; }
			public string Nationality { get; set; }
			public int Years { get; set; }

			public static void ValidateAndSetDefaults(List<Pax> paxList, bool isFirstCabin, ref string defaultGroup)
			{
				bool isFirstPax = isFirstCabin;
				foreach(Pax pax in paxList)
				{
					if(isFirstPax)
					{
						if(String.IsNullOrWhiteSpace(pax.Group))
							throw new BookingException("Group must be set for the first pax.");
						defaultGroup = pax.Group;
					}
					else if(String.IsNullOrWhiteSpace(pax.Group))
						pax.Group = defaultGroup;

					isFirstPax = false;

					if(String.IsNullOrWhiteSpace(pax.FirstName))
						throw new BookingException("First name must be set.");
					if(String.IsNullOrWhiteSpace(pax.LastName))
						throw new BookingException("Last name must be set.");
					if(!DateOfBirth.IsValid(pax.Dob))
						throw new BookingException("Date of birth must be set and a valid date.");

					if(String.IsNullOrWhiteSpace(pax.Nationality))
						pax.Nationality = DefaultNationality;
					else if(!TryValidateNationality(pax.Nationality))
						throw new BookingException("Nationality must be a 2-letter ISO country code.");
					else
						pax.Nationality = pax.Nationality.ToLowerInvariant();

					if(pax.Years < 0)
						throw new BookingException("Years must be greater than or equal to zero.");
				}
			}

			static bool TryValidateNationality(string nationality)
			{
				return Regex.IsMatch(nationality, "^[a-z]{2}$", RegexOptions.IgnoreCase);
			}
		}
	}
}
