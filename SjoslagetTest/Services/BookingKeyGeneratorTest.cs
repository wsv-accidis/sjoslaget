using System.Linq;
using System.Text.RegularExpressions;
using Accidis.WebServices.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class BookingKeyGeneratorTest
	{
		[TestMethod]
		public void ShouldProduceOnlyValidPinCodes()
		{
			var sut = new BookingKeyGenerator();

			for(int i = 0; i < 1000; i++)
			{
				string pinCode = sut.GeneratePinCode();
				Assert.AreEqual(BookingKeyGenerator.PinCodeLength, pinCode.Length);
				Assert.IsTrue(pinCode.All(char.IsDigit));
			}
		}

		[TestMethod]
		public void ShouldProduceOnlyValidReferences()
		{
			var sut = new BookingKeyGenerator();
			var regex = new Regex(BookingKeyGenerator.BookingReferencePattern, RegexOptions.Compiled);

			for(int i = 0; i < 1000; i++)
			{
				string reference = sut.GenerateBookingReference();
				Assert.AreEqual(BookingKeyGenerator.BookingReferenceLength, reference.Length);
				Assert.IsTrue(regex.Match(reference).Success);
			}
		}
	}
}
