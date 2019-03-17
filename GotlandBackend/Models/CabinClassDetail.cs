using System;

namespace Accidis.Gotland.WebService.Models
{
	public class CabinClassDetail
	{
		public Guid Id { get; set; }
		public string Title { get; set; }
		public int No { get; set; }
		public int Capacity { get; set; }
		public int Count { get; set; }
	}
}
