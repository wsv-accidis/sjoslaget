using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingOverviewItem
	{
		public Guid Id { get; set; }
		public string Reference { get; set; }
		public string SubCruise { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Lunch { get; set; }
		public decimal TotalPrice { get; set; }
		public decimal AmountPaid { get; set; }
		public int NumberOfCabins { get; set; }
		public bool IsLocked { get; set; }
		public DateTime Updated { get; set; }
	}
}
