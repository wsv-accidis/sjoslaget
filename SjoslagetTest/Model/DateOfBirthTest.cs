using System;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Model
{
	[TestClass]
	public class DateOfBirthTest
	{
		[TestMethod]
		public void GivenDateOfBirth_ShouldCorrectlyCalculateAge()
		{
			var test = new DateOfBirth("870412");

			var beforeBirthday = new DateTime(2017, 4, 2);
			Assert.AreEqual(29, test.AgeOn(beforeBirthday));

			var onBirthday = new DateTime(2017, 4, 12);
			Assert.AreEqual(30, test.AgeOn(onBirthday));

			var afterBirthday = new DateTime(2017, 4, 15);
			Assert.AreEqual(30, test.AgeOn(afterBirthday));

			afterBirthday = new DateTime(2017, 8, 1);
			Assert.AreEqual(30, test.AgeOn(afterBirthday));
		}

		[TestMethod]
		public void GivenDateOfBirth_ShouldCorrectlyParseIt()
		{
			var test = new DateOfBirth("830412");
			Assert.AreEqual(1983, test.Year);
			Assert.AreEqual(4, test.Month);
			Assert.AreEqual(12, test.Day);
		}

		[TestMethod]
		public void GivenDateOfBirth_WhichHasYearInThe00s_ShouldInterpretAsAfter2000()
		{
			var test = new DateOfBirth("040101");
			Assert.AreEqual(2004, test.Year);
			Assert.AreEqual(1, test.Month);
			Assert.AreEqual(1, test.Day);
		}
	}
}
