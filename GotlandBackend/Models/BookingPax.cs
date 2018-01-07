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
		public string Nationality { get; set; }
		public Guid OutboundTripId { get; set; }
		public Guid InboundTripId { get; set; }
		public bool IsStudent { get; set; }
		public int CabinClassMin { get; set; }
		public int CabinClassPreferred { get; set; }
		public int CabinClassMax { get; set; }
		public string SpecialFood { get; set; }
		public DateTime Created { get; set; }
	}
}
