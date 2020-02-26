using Accidis.WebServices.Auth;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class CredentialsGenerator : AecCredentialsGenerator
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"[0-9][A-Z0-9]{5}";

		public override string GenerateBookingReference()
		{
			return GenerateBookingReference(BookingReferenceLength);
		}
	}
}
