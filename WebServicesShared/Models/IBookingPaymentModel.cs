using System;

namespace Accidis.WebServices.Models
{
	public interface IBookingPaymentModel
	{
		Guid Id { get; }
		string Reference { get; }
		int Discount { get; set; }
	}
}
