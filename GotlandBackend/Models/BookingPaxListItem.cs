using System;

namespace Accidis.Gotland.WebService.Models
{
	public class BookingPaxListItem
	{
		public Guid Id { get; set; }
		public string Reference { get; set; }
		public string TeamName { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Gender { get; set; }
		public string Dob { get; set; }
		public int CabinClassMin { get; set; }
		public int CabinClassPreferred { get; set; }
		public int CabinClassMax { get; set; }
	}
}
