﻿using System;
using Accidis.WebServices.Models;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class Booking : IBookingPaymentModel
	{
		public Guid Id { get; set; }
		public Guid EventId { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public string GroupName { get; set; }
		public string SpecialRequest { get; set; }
		public string InternalNotes { get; set; }
		public int Discount { get; set; }
		public decimal TotalPrice { get; set; }
		public Guid? CandidateId { get; set; }
		public int QueueNo { get; set; }
		public bool IsLocked { get; set; }
		public DateTime? ConfirmationSent { get; set; }
		public DateTime Created { get; set; }
		public DateTime Updated { get; set; }

		public static Booking FromCandidate(BookingCandidate candidate, int placeInQueue, Guid evntId, string reference)
		{
			return new Booking
			{
				EventId = evntId,
				Reference = reference,
				FirstName = candidate.FirstName,
				LastName = candidate.LastName,
				Email = candidate.Email,
				PhoneNo = candidate.PhoneNo,
				TeamName = candidate.TeamName,
				GroupName = candidate.GroupName,
				QueueNo = placeInQueue
			};
		}
	}
}