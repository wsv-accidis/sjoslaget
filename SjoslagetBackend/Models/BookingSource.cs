using System;
using System.Collections.Generic;
using System.Linq;
using Accidis.WebServices.Models;

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
		public int Discount { get; set; }
		public bool IsLocked { get; set; }
		public string InternalNotes { get; set; }
		public string SubCruise { get; set; }
		public List<Cabin> Cabins { get; set; }
		public List<Product> Products { get; set; }
		public PaymentSummary Payment { get; set; }

		public static BookingSource FromBooking(Booking booking, BookingCabinWithPax[] cabins, BookingProduct[] products, PaymentSummary payment)
		{
			return new BookingSource
			{
				Reference = booking.Reference,
				FirstName = booking.FirstName,
				LastName = booking.LastName,
				Email = booking.Email,
				PhoneNo = booking.PhoneNo,
				Lunch = booking.Lunch,
				Discount = booking.Discount,
				InternalNotes = booking.InternalNotes,
				SubCruise = booking.SubCruise.ToString(),
				IsLocked = booking.IsLocked,
				Cabins = cabins.Select(c => new Cabin
				{
					TypeId = c.CabinTypeId,
					Pax = c.Pax.Select(p => new Pax
					{
						Group = p.Group,
						FirstName = p.FirstName,
						LastName = p.LastName,
						Gender = p.Gender.ToString(),
						Dob = p.Dob.ToString(),
						Nationality = p.Nationality.ToUpperInvariant(),
						Years = p.Years
					}).ToList()
				}).ToList(),
				Products = products.Select(p => new Product
				{
					TypeId = p.ProductTypeId,
					Quantity = p.Quantity
				}).ToList(),
				Payment = payment
			};
		}

		public static void Validate(BookingSource bookingSource)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");

			bookingSource.ValidateDetails();
			bookingSource.ValidateCabins();
			bookingSource.ValidateProducts();
		}

		public static void ValidateCabins(BookingSource bookingSource)
		{
			if(null == bookingSource)
				throw new ArgumentNullException(nameof(bookingSource), "Booking data not present.");
			if(null == bookingSource.SubCruise)
				throw new BookingException("Sub-cruise must be set.");

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

		void ValidateProducts()
		{
			if(null == Products || !Products.Any())
				return; // No products on booking is just peachy

			foreach(Product product in Products)
				product.Validate();
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
			public string Group { get; set; }
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string Gender { get; set; }
			public string Dob { get; set; }
			public string Nationality { get; set; }
			public int Years { get; set; }

			internal static void ValidateAndSetDefaults(List<Pax> paxList, bool isFirstCabin, ref string defaultGroup)
			{
				bool isFirstPax = isFirstCabin;
				foreach(Pax pax in paxList)
				{
					if(isFirstPax)
					{
						if(string.IsNullOrWhiteSpace(pax.Group))
							throw new BookingException("Group must be set for the first pax.");
						defaultGroup = pax.Group;
					}
					else if(string.IsNullOrWhiteSpace(pax.Group))
						pax.Group = defaultGroup;

					isFirstPax = false;

					if(string.IsNullOrWhiteSpace(pax.FirstName))
						throw new BookingException("First name must be set.");
					if(string.IsNullOrWhiteSpace(pax.LastName))
						throw new BookingException("Last name must be set.");
					if(!DateOfBirth.IsValid(pax.Dob))
						throw new BookingException("Date of birth must be set and a valid date.");
					if(!IsoNationality.TryValidateOrSetDefault(pax.Nationality, out var nationality))
						throw new BookingException("Nationality must be a 2-letter ISO country code.");
					pax.Nationality = nationality;

					if(pax.Years < 0)
						throw new BookingException("Years must be greater than or equal to zero.");
				}
			}
		}

		public sealed class Product
		{
			public Guid TypeId { get; set; }
			public int Quantity { get; set; }

			public void Validate()
			{
				if(Guid.Empty.Equals(TypeId))
					throw new BookingException("Product type must be specified.");
				if(Quantity <= 0)
					throw new BookingException("Product quantity must be positive.");
			}
		}
	}
}
