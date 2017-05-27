using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingPaxItem
	{
		public Guid Id { get; set; }
		public Guid CabinTypeId { get; set; }
		public string Reference { get; set; }
		public string Group { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Gender { get; set; }
		public string Dob { get; set; }
		public string Nationality { get; set; }
		public int Years { get; set; }
	}
}
