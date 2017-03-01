using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class AvailabilityException : Exception
	{
		public AvailabilityException(string message) : base(message)
		{
		}
	}
}
