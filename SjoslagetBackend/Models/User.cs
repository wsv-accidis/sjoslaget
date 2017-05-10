using System;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class User : IUser<Guid>
	{
		public Guid Id { get; set; }
		public string UserName { get; set; }
		public string Password { get; set; }
		public string PasswordHash { get; set; }
		public string SecurityStamp { get; set; }
		public bool IsBooking { get; set; }
	}
}
