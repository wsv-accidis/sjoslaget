namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class IsLockedResult
	{
		public bool IsLocked { get; set; }

		public static IsLockedResult FromBooking(Booking booking)
		{
			return new IsLockedResult {IsLocked = booking.IsLocked};
		}

		public static IsLockedResult FromCruise(Cruise cruise)
		{
			return new IsLockedResult {IsLocked = cruise.IsLocked};
		}
	}
}
