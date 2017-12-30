using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class Event
	{
		public Guid Id { get; set; }
		public string Name { get; set; }
		public bool IsActive { get; set; }
		public DateTime? Opening { get; set; }

		public bool IsOpen => Opening.HasValue && DateTime.Now > Opening.Value;
	}
}
