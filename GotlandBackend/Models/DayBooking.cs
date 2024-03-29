﻿using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class DayBooking
	{
		public Guid Id { get; set; }
		public Guid EventId { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string Gender { get; set; }
		public string Dob { get; set; }
		public string Food { get; set; }
		public Guid TypeId { get; set; }
		public bool PaymentConfirmed { get; set; }
		public DateTime? ConfirmationSent { get; set; }
		public DateTime Created { get; set; }
		public DateTime Updated { get; set; }
	}
}
