using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Cruise
	{
		public Guid Id { get; set; }
		public string Name { get; set; }
		public bool IsActive { get; set; }
	}
}
