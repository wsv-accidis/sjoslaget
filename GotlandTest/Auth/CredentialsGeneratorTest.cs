﻿using System.Linq;
using System.Text.RegularExpressions;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Auth;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Gotland.Test.Auth
{
	[TestClass]
	public class CredentialsGeneratorTest
	{
		[TestMethod]
		public void ShouldProduceOnlyValidPinCodes()
		{
			var sut = new CredentialsGenerator();

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
			var sut = new CredentialsGenerator();
			var regex = new Regex(CredentialsGenerator.BookingReferencePattern, RegexOptions.Compiled);

			for(int i = 0; i < 1000; i++)
			{
				string reference = sut.GenerateBookingReference();
				Assert.AreEqual(CredentialsGenerator.BookingReferenceLength, reference.Length);
				Assert.IsTrue(regex.Match(reference).Success);
			}
		}
	}
}
