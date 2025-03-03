using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class ClaimSource
	{
		public Guid CandidateId { get; set; }
		public string ChallengeResponse { get; set; }

		public bool IsValidResponseTo(ChallengeResponse expected)
		{
			if(string.IsNullOrWhiteSpace(ChallengeResponse))
				return false;

			return string.Equals(ChallengeResponse.Trim(), expected.Response.Trim(),
				StringComparison.InvariantCultureIgnoreCase);
		}
	}
}
