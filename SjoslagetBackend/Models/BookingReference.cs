namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingReference
	{
		public BookingReference(string reference)
		{
			Reference = reference;
		}

		public string Reference { get; set; }
	}
}
