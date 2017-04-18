using System;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("Email.config")]
	public class EmailSenderTest
	{
		[Ignore]
		[TestMethod]
		public async Task GivenValidRecipient_ShouldSendEmail()
		{
			const string recipient = "wilhelm.svenselius@gmail.com";
			string subject = "Test sent on " + DateTime.Now;
			string body = "Hello, e-mail reader! This e-mail was sent by the test " + typeof(EmailSenderTest).Name + ".";

			using(var sender = new EmailSender())
				await sender.SendMailAsync(recipient, subject, body);
		}

		[Ignore]
		[TestMethod]
		public async Task GivenValidDetails_ShouldSendBookingCreatedEmail()
		{
			const string recipient = "wilhelm.svenselius@gmail.com";
			const string bookingRef = "ABC123";
			const string pinCode = "4567";

			using (var sender = new EmailSender())
				await sender.SendBookingCreatedMailAsync(recipient, bookingRef, pinCode);
		}
	}
}
