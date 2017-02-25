using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public class CabinType
	{
		public Guid Id { get; set; }
		public string Name { get; set; }
		public string Description { get; set; }
		public int Capacity { get; set; }
	}
}