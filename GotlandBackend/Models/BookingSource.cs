using System;
using System.Collections.Generic;
using System.Linq;
using Accidis.WebServices.Models;

namespace Accidis.Gotland.WebService.Models
{
	public class BookingSource
	{
		public const int MaximumPaxInBooking = 20;
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public string GroupName { get; set; }
		public string SpecialRequest { get; set; }
		public string InternalNotes { get; set; }
		public int Discount { get; set; }
		public DateTime? ConfirmationSent { get; set; }
		public List<PaxSource> Pax { get; set; }
		public PaymentSummary Payment { get; set; }

		public static BookingSource FromBooking(Booking booking, BookingPax[] pax, PaymentSummary payment)
		{
			return new BookingSource
			{
				Reference = booking.Reference,
				FirstName = booking.FirstName,
				LastName = booking.LastName,
				Email = booking.Email,
				PhoneNo = booking.PhoneNo,
				TeamName = booking.TeamName,
				GroupName = booking.GroupName,
				SpecialRequest = booking.SpecialRequest,
				InternalNotes = booking.InternalNotes,
				Discount = booking.Discount,
				ConfirmationSent = booking.ConfirmationSent,
				Pax = pax.Select(p => new PaxSource
				{
					FirstName = p.FirstName,
					LastName = p.LastName,
					Gender = p.Gender.ToString(),
					Dob = p.Dob.ToString(),
					Food = p.Food,
					CabinClassMin = p.CabinClassMin,
					CabinClassPreferred = p.CabinClassPreferred,
					CabinClassMax = p.CabinClassMax,
				}).ToList(),
				Payment = payment
			};
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

		public static void ValidatePax(BookingSource bookingSource)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidatePax();
		}

		public void ValidatePax()
		{
			if(null == Pax)
				return;

			if(Pax.Count > MaximumPaxInBooking)
				throw new BookingException("Maximum number of pax exceeded.");

			foreach(PaxSource pax in Pax)
			{
				pax.ValidateDetailsAndSetDefaults();
				pax.ValidateCabinClasses();
			}
		}

		public sealed class PaxSource
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string Gender { get; set; }
			public string Dob { get; set; }
			public string Food { get; set; }
			public int CabinClassMin { get; set; }
			public int CabinClassPreferred { get; set; }
			public int CabinClassMax { get; set; }

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
				if(String.IsNullOrEmpty(Food))
					throw new BookingException("Food must be set.");
			}
		}
	}
}