using System;

namespace Accidis.Gotland.WebService.Models
{
	public class ExternalBookingSource
	{
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string Gender { get; set; }
		public string Dob { get; set; }
		public string Food { get; set; }
		public Guid TypeId { get; set; }
	}
}
