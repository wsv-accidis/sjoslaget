using Accidis.Gotland.WebService.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Gotland.Test.Models
{
	[TestClass]
	public class ClaimSourceTest
	{
		[TestMethod]
		public void ShouldCorrectlyIdentifyCorrectResponses()
		{
			Assert.IsTrue(IsValid("1", "1"));
			Assert.IsTrue(IsValid("ett", "ett "));
			Assert.IsTrue(IsValid("två", " TVÅ"));
			Assert.IsTrue(IsValid("sverige", "Sverige"));
			Assert.IsTrue(IsValid("102", "	102	"));
		}

		[TestMethod]
		public void ShouldCorrectlyIdentifyWrongResponses()
		{
			Assert.IsFalse(IsValid("1", ""));
			Assert.IsFalse(IsValid("2", null));
			Assert.IsFalse(IsValid("sverige", "finland"));
			Assert.IsFalse(IsValid("102", "101"));
		}

		bool IsValid(string expectedResponse, string actualResponse)
		{
			var challengeResponse = new ChallengeResponse { Response = expectedResponse };
			var claimSource = new ClaimSource { ChallengeResponse = actualResponse };
			return claimSource.IsValidResponseTo(challengeResponse);
		}
	}
}
