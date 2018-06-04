using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingChange
	{
		public const string Added = "Added";
		public const string Removed = "Removed";
		public const int IndexWholeCabin = -1;

		public Guid BookingId { get; set; }
		public int CabinIndex { get; set; }
		public int PaxIndex { get; set; }
		public string FieldName { get; set; }
		public DateTime Updated { get; set; }
	}
}
