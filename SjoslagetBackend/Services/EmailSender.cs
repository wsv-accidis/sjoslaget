using System.Text;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Content;
using Accidis.WebServices.Services;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class EmailSender : AecEmailSender
	{
		const string CruiseNameKey = "{CRUISE_NAME}";
		const string BookingRefKey = "{BOOKING_REF}";
		const string PinCodeKey = "{PIN_CODE}";

		public async Task SendBookingCreatedMailAsync(string cruiseName, string recipient, string bookingRef, string pinCode)
		{
			var buffer = new StringBuilder(Emails.BookingCreatedEmail);
			buffer.Replace(CruiseNameKey, cruiseName);
			buffer.Replace(BookingRefKey, bookingRef);
			buffer.Replace(PinCodeKey, pinCode);

			var subject = Emails.BookingCreatedSubject.Replace(CruiseNameKey, cruiseName);

			await SendMailAsync(recipient, subject, buffer.ToString());
		}
	}
}
