using System;

namespace Accidis.WebServices.Models
{
	public sealed class Payment
	{
		public decimal Amount { get; set; }
		public DateTime Created { get; set; }
	}
}
