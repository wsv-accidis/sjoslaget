using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class AllocationListItem
	{
		public Guid CabinId { get; set; }
		public string Reference { get; set; }
		public string TeamName { get; set; }
		public string Note { get; set; }
		public int NumberOfPax { get; set; }
		public int TotalPax { get; set; }
	}
}
