using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Report
	{
		public Guid Id { get; set; }
		public Guid CruiseId { get; set; }
		public DateTime Date { get; set; }
		public int BookingsCreated { get; set; }
		public int BookingsTotal { get; set; }
		public int CabinsTotal { get; set; }
		public int PaxTotal { get; set; }
		public int CapacityTotal { get; set; }
		public DateTime Created { get; set; }
	}
}
