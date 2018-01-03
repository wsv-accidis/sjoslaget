using System.Linq;
using System.Security.Cryptography;

namespace Accidis.WebServices.Auth
{
	public sealed class AecCredentialsGenerator
	{
		public const int BookingReferenceLength = 6;
		public const string BookingReferencePattern = @"[0-9][A-Z0-9]{5}";
		public const int PinCodeLength = 4;

		const string Letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		const string LettersAndNumbers = Letters + Numbers;
		const string Numbers = "0123456789";

		readonly RandomNumberGenerator _rng = RandomNumberGenerator.Create();

		public string GenerateBookingReference()
		{
			var rngBytes = new byte[BookingReferenceLength];
			_rng.GetBytes(rngBytes);

			var buffer = new char[BookingReferenceLength];
			buffer[0] = ByteToChar(Numbers, rngBytes[0]); // first char is always a number
			for(int i = 1; i < BookingReferenceLength; i++)
				buffer[i] = ByteToChar(LettersAndNumbers, rngBytes[i]);

			return new string(buffer);
		}

		public string GeneratePinCode()
		{
			var rngBytes = new byte[PinCodeLength];
			_rng.GetBytes(rngBytes);

			return new string(rngBytes.Select(b => ByteToChar(Numbers, b)).ToArray());
		}

		static char ByteToChar(string set, byte random) => set[random % set.Length];
	}
}
