using System.Linq;
using System.Text.RegularExpressions;
using Accidis.WebServices.Auth;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class AecCredentialsGeneratorTest
	{
		[TestMethod]
		public void ShouldProduceOnlyValidPinCodes()
		{
			var sut = new AecCredentialsGenerator();

			for(int i = 0; i < 1000; i++)
			{
				string pinCode = sut.GeneratePinCode();
				Assert.AreEqual(AecCredentialsGenerator.PinCodeLength, pinCode.Length);
				Assert.IsTrue(pinCode.All(char.IsDigit));
			}
		}

		[TestMethod]
		public void ShouldProduceOnlyValidReferences()
		{
			var sut = new AecCredentialsGenerator();
			var regex = new Regex(AecCredentialsGenerator.BookingReferencePattern, RegexOptions.Compiled);

			for(int i = 0; i < 1000; i++)
			{
				string reference = sut.GenerateBookingReference();
				Assert.AreEqual(AecCredentialsGenerator.BookingReferenceLength, reference.Length);
				Assert.IsTrue(regex.Match(reference).Success);
			}
		}
	}
}
