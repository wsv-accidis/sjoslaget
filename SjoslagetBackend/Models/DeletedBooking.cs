using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class DeletedBooking
	{
		public Guid Id { get; set; }
		public Guid CruiseId { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public decimal TotalPrice { get; set; }
		public decimal AmountPaid { get; set; }
		public DateTime Created { get; set; }
		public DateTime Updated { get; set; }
		public DateTime Deleted { get; set; }

		public static DeletedBooking FromBooking(Booking booking, decimal amountPaid)
		{
			return new DeletedBooking
			{
				CruiseId = booking.CruiseId,
				Reference = booking.Reference,
				FirstName = booking.FirstName,
				LastName = booking.LastName,
				Email = booking.Email,
				PhoneNo = booking.PhoneNo,
				TotalPrice = booking.TotalPrice,
				AmountPaid = amountPaid,
				Created = booking.Created,
				Updated = booking.Updated
			};
		}
	}
}
