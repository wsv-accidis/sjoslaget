using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingOverviewItem
	{
		public Guid Id { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public decimal TotalPrice { get; set; }
		public decimal AmountPaid { get; set; }
		public int NumberOfCabins { get; set; }
		public DateTime Updated { get; set; }
	}
}
