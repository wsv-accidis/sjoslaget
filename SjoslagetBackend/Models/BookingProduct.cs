using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingProduct
	{
		public Guid Id { get; set; }
		public Guid BookingId { get; set; }
		public Guid ProductTypeId { get; set; }
		public int Quantity { get; set; }
	}
}
