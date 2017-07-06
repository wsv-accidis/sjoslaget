namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class UserPasswordChange
	{
		public string Username { get; set; }
		public string CurrentPassword { get; set; }
		public string NewPassword { get; set; }
		public bool ForceReset { get; set; }
	}
}
