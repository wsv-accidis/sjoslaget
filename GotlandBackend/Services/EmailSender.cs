using System.Text;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Content;
using Accidis.WebServices.Services;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class EmailSender : AecEmailSender
	{
		const string EventNameKey = "{EVENT_NAME}";
		const string BookingRefKey = "{BOOKING_REF}";
		const string PinCodeKey = "{PIN_CODE}";

		public async Task SendBookingCreatedMailAsync(string eventName, string recipient, string bookingRef, string pinCode)
		{
			var buffer = new StringBuilder(Emails.BookingCreatedEmail);
			buffer.Replace(EventNameKey, eventName);
			buffer.Replace(BookingRefKey, bookingRef);
			buffer.Replace(PinCodeKey, pinCode);

			var subject = Emails.BookingCreatedSubject.Replace(EventNameKey, eventName);

			await SendMailAsync(recipient, subject, buffer.ToString());
		}

		public async Task SendBookingConfirmedMailAsync(string eventName, string recipient, string bookingRef)
		{
			var buffer = new StringBuilder(Emails.BookingConfirmedEmail);
			buffer.Replace(EventNameKey, eventName);
			buffer.Replace(BookingRefKey, bookingRef);

			var subject = Emails.BookingConfirmedSubject.Replace(EventNameKey, eventName);

			await SendMailAsync(recipient, subject, buffer.ToString());
		}
	}
}
