using System;

namespace Accidis.WebServices.Exceptions
{
	public class ImageException : Exception
	{
		public ImageException(string message) : base(message)
		{
		}

		public ImageException(string message, Exception innerException) : base(message, innerException)
		{
		}
	}
}