using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class BookingException : Exception
	{
		public BookingException(string message) : base(message)
		{
		}
	}
}
