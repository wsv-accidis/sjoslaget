using Accidis.WebServices.Auth;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class CredentialsGenerator : AecCredentialsGenerator
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"(AG|DB)[0-9][A-Z0-9]{3}";
		const int GeneratedBookingReferenceLength = 4;
		const string BookingReferencePrefix = "AG";
		const string DayBookingReferencePrefix = "DB";

		public override string GenerateBookingReference()
		{
			return BookingReferencePrefix + GenerateBookingReference(GeneratedBookingReferenceLength);
		}

		public string GenerateDayBookingReference()
		{
			return DayBookingReferencePrefix + GenerateBookingReference(GeneratedBookingReferenceLength);
		}
	}
}
