using Accidis.WebServices.Auth;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class CredentialsGenerator : AecCredentialsGenerator
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"AG[0-9][A-Z0-9]{3}";
		const int GeneratedBookingReferenceLength = 4;
		const string BookingReferencePrefix = "AG";

		public override string GenerateBookingReference()
		{
			return BookingReferencePrefix + GenerateBookingReference(GeneratedBookingReferenceLength);
		}
	}
}
