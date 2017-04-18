using System;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Content;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class EmailSender : IDisposable
	{
		readonly SmtpClient _client = new SmtpClient {EnableSsl = true};

		public void Dispose()
		{
			_client?.Dispose();
		}

		public async Task SendBookingCreatedMailAsync(string recipient, string bookingRef, string pinCode)
		{
			var buffer = new StringBuilder(Emails.BookingCreatedEmail);
			buffer.Replace("{BOOKING_REF}", bookingRef);
			buffer.Replace("{PIN_CODE}", pinCode);

			const string subject = "Din bokning till Sjöslaget";
			await SendMailAsync(recipient, subject, buffer.ToString());
		}

		public async Task SendMailAsync(string recipient, string subject, string body)
		{
			var message = new MailMessage();
			message.To.Add(recipient);
			message.Subject = subject;
			message.Body = body;

			await _client.SendMailAsync(message);
		}
	}
}
