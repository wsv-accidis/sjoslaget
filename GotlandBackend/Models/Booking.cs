﻿using System;

namespace Accidis.Gotland.WebService.Models
{
	public sealed class Booking
	{
		public Guid Id { get; set; }
		public Guid EventId { get; set; }
		public string Reference { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public string Email { get; set; }
		public string PhoneNo { get; set; }
		public string TeamName { get; set; }
		public decimal TotalPrice { get; set; }
		public int QueueNo { get; set; }
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
				QueueNo = placeInQueue
			};
		}
	}
}
