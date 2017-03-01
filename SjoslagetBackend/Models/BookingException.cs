using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingException : Exception
	{
		public BookingException(string message) : base(message)
		{
		}
	}
}
