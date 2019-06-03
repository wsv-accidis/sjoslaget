using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidate
	{
		public Guid Id { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public int TeamSize { get; set; }
		public DateTime Created { get; set; }

		public static void Validate(BookingCandidate candidate)
		{
			if(string.IsNullOrWhiteSpace(candidate.FirstName))
				throw new BookingException("First name must be set.");
			if(string.IsNullOrWhiteSpace(candidate.LastName))
				throw new BookingException("Last name must be set.");
			if(string.IsNullOrWhiteSpace(candidate.Email))
				throw new BookingException("E-mail must be set.");
			if(string.IsNullOrWhiteSpace(candidate.PhoneNo))
				throw new BookingException("Phone number must be set.");
			if(string.IsNullOrWhiteSpace(candidate.TeamName))
				throw new BookingException("Team name must be set.");
			if(candidate.TeamSize <= 0)
				throw new BookingException("Team size must be greater than zero.");
			if(candidate.TeamSize > BookingSource.MaximumPaxInBooking)
				throw new BookingException("Team size is too large.");
		}
	}
}
