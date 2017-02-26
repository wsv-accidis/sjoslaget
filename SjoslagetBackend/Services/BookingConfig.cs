namespace Accidis.Sjoslaget.WebService.Services
{
	static class BookingConfig
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"[0-9][A-Za-z0-9]{5}";
		public const int PinCodeLength = 4;
	}
}
