using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class ExternalBooking
	{
		public Guid Id { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Dob { get; set; }
		public string PhoneNo { get; set; }
		public string SpecialRequest { get; set; }
		public Guid TypeId { get; set; }
		public bool PaymentReceived { get; set; }
		public bool PaymentConfirmed { get; set; }
		public DateTime Created { get; set; }
	}
}
