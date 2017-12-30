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
			if (string.IsNullOrWhiteSpace(candidate.FirstName))
				throw new BookingException("First name must be set.");
			if (string.IsNullOrWhiteSpace(candidate.LastName))
				throw new BookingException("Last name must be set.");

			// TODO Validate more
			candidate.Email = candidate.Email ?? String.Empty;
			candidate.PhoneNo = candidate.PhoneNo ?? String.Empty;
			candidate.TeamName = candidate.TeamName ?? String.Empty;			
		}
	}
}
