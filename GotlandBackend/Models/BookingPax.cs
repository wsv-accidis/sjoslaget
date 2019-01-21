using System;
using Accidis.WebServices.Models;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingPax
	{
		public Guid Id { get; set; }
		public Guid BookingId { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public Gender Gender { get; set; }
		public DateOfBirth Dob { get; set; }
		public int CabinClassMin { get; set; }
		public int CabinClassPreferred { get; set; }
		public int CabinClassMax { get; set; }
		public string SpecialRequest { get; set; }

		public static BookingPax FromSource(BookingSource.PaxSource source, Guid bookingId)
		{
			return new BookingPax
			{
				BookingId = bookingId,
				FirstName = source.FirstName,
				LastName = source.LastName,
				Gender = Gender.FromString(source.Gender),
				Dob = new DateOfBirth(source.Dob),
				CabinClassMin = source.CabinClassMin,
				CabinClassPreferred = source.CabinClassPreferred,
				CabinClassMax = source.CabinClassMax,
				SpecialRequest = source.SpecialRequest
			};
		}
	}
}
