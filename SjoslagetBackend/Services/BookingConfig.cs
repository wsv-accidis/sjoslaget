namespace Accidis.Sjoslaget.WebService.Services
{
	public static class BookingConfig
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"[0-9][A-Z0-9]{5}";
		public const int PinCodeLength = 4;
	}
}
