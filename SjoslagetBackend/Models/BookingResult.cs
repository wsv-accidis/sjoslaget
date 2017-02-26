namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingResult
	{
		public string Reference { get; set; }
		public string Password { get; set; }

		public static BookingResult FromBooking(Booking booking, string password)
		{
			return new BookingResult
			{
				Reference = booking.Reference,
				Password = password
			};
		}
	}
}
