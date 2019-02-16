using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingListItem
	{
		public Guid Id { get; set; }
		public string Reference { get; set; }
		public string TeamName { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public decimal TotalPrice { get; set; }
		public int NumberOfPax { get; set; }
		public int QueueNo { get; set; }
		public DateTime Updated { get; set; }

		// TODO: AmountPaid, HasCabins
	}
}
