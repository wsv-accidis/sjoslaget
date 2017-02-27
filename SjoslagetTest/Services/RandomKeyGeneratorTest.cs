using System.Linq;
using System.Text.RegularExpressions;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class RandomKeyGeneratorTest
	{
		[TestMethod]
		public void ShouldProduceOnlyValidPinCodes()
		{
			var sut = new RandomKeyGenerator();

			for(int i = 0; i < 1000; i++)
			{
				string pinCode = sut.GeneratePinCode();
				Assert.AreEqual(BookingConfig.PinCodeLength, pinCode.Length);
				Assert.IsTrue(pinCode.All(char.IsDigit));
			}
		}

		[TestMethod]
		public void ShouldProduceOnlyValidReferences()
		{
			var sut = new RandomKeyGenerator();
			var regex = new Regex(BookingConfig.BookingReferencePattern, RegexOptions.Compiled);

			for(int i = 0; i < 1000; i++)
			{
				string reference = sut.GenerateBookingReference();
				Assert.AreEqual(BookingConfig.BookingReferenceLength, reference.Length);
				Assert.IsTrue(regex.Match(reference).Success);
			}
		}
	}
}
