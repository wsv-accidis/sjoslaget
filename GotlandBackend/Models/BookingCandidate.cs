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
			// TODO Actually validate

			candidate.FirstName = candidate.FirstName ?? String.Empty;
			candidate.LastName = candidate.LastName ?? String.Empty;
			candidate.Email = candidate.Email ?? String.Empty;
			candidate.PhoneNo = candidate.PhoneNo ?? String.Empty;
			candidate.TeamName = candidate.TeamName ?? String.Empty;			
		}
	}
}
