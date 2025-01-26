using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidate
	{
		const int MaxChars = 64;

		public Guid Id { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public string GroupName { get; set; }
		public int TeamSize { get; set; }
		public DateTime Created { get; set; }

		public static void Validate(BookingCandidate candidate)
		{
			if(string.IsNullOrWhiteSpace(candidate.FirstName))
				throw new BookingException("First name must be set.");
			if(candidate.FirstName.Length > MaxChars)
				throw new BookingException("First name is too long.");
			if(string.IsNullOrWhiteSpace(candidate.LastName))
				throw new BookingException("Last name must be set.");
			if(candidate.LastName.Length > MaxChars)
				throw new BookingException("Last name is too long.");
			if(string.IsNullOrWhiteSpace(candidate.Email))
				throw new BookingException("E-mail must be set.");
			if(candidate.Email.Length > MaxChars)
				throw new BookingException("E-mail name is too long.");
			if(string.IsNullOrWhiteSpace(candidate.PhoneNo))
				throw new BookingException("Phone number must be set.");
			if(candidate.PhoneNo.Length > MaxChars)
				throw new BookingException("Phone name is too long.");
			if(string.IsNullOrWhiteSpace(candidate.TeamName))
				throw new BookingException("Team name must be set.");
			if(candidate.TeamName.Length > MaxChars)
				throw new BookingException("Team name is too long.");
			if(candidate.TeamSize <= 0)
				throw new BookingException("Team size must be greater than zero.");
			if(candidate.TeamSize > BookingSource.MaximumPaxInBooking)
				throw new BookingException("Team size is too large.");
		}
	}
}