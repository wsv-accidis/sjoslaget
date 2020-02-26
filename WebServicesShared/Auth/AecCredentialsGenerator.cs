using System.Linq;
using System.Security.Cryptography;

namespace Accidis.WebServices.Auth
{
	public abstract class AecCredentialsGenerator
	{
		public const int PinCodeLength = 4;

		const string Letters = "ABCDEFGHJKLMNPQRSTUVWX";
		const string LettersAndNumbers = Letters + Numbers;
		const string Numbers = "0123456789";

		readonly RandomNumberGenerator _rng = RandomNumberGenerator.Create();

		public abstract string GenerateBookingReference();

		protected string GenerateBookingReference(int length)
		{
			var rngBytes = new byte[length];
			_rng.GetBytes(rngBytes);

			var buffer = new char[length];
			buffer[0] = ByteToChar(Numbers, rngBytes[0]); // first char is always a number
			for(int i = 1; i < length; i++)
				buffer[i] = ByteToChar(LettersAndNumbers, rngBytes[i]);

			return new string(buffer);
		}

		public string GeneratePinCode()
		{
			return GeneratePinCode(PinCodeLength);
		}

		protected string GeneratePinCode(int length)
		{
			var rngBytes = new byte[length];
			_rng.GetBytes(rngBytes);

			return new string(rngBytes.Select(b => ByteToChar(Numbers, b)).ToArray());
		}

		static char ByteToChar(string set, byte random)
		{
			return set[random % set.Length];
		}
	}
}
