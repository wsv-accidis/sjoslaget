using System;
using System.Net.Mail;
using System.Threading.Tasks;

namespace Accidis.WebServices.Services
{
	public class AecEmailSender : IDisposable
	{
		readonly SmtpClient _client = new SmtpClient { EnableSsl = true };

		public void Dispose()
		{
			_client?.Dispose();
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