using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingCandidateReusedException : Exception
	{
		public BookingCandidateReusedException(string existingReference) : base()
		{
			ExistingReference = existingReference;
		}

		public string ExistingReference { get; private set; }
	}
}