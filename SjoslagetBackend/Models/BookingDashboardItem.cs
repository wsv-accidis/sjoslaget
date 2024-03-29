﻿using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class BookingDashboardItem
	{
		public Guid Id { get; set; }
		public string Reference { get; set; }
		public string SubCruise { get; set; }
		public string FirstName { get; set; }
		public string LastName { get; set; }
		public DateTime Created { get; set; }
		public DateTime Updated { get; set; }
		public int NumberOfCabins { get; set; }
		public int NumberOfPax { get; set; }
	}
}
