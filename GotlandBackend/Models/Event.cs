using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class Event
	{
		// Event will not display as open until 
		const int BeforeOpeningCountdownDays = 7;

		public Guid Id { get; set; }
		public string Name { get; set; }
		public bool IsActive { get; set; }
		public bool IsLocked { get; set; }
		public DateTime? Opening { get; set; }

		public bool IsOpen => !IsLocked && Opening.HasValue && DateTime.Now > Opening.Value;

		public bool IsInCountdown
		{
			get
			{
				if(!IsLocked && Opening.HasValue)
				{
					var now = DateTime.Now;
					var limit = Opening.Value.AddDays(-BeforeOpeningCountdownDays);
					return now < Opening.Value && now > limit;
				}

				return false;
			}
		}
	}
}
