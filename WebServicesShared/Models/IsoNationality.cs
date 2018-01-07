using System;
using System.Text.RegularExpressions;

namespace Accidis.WebServices.Models
{
	public static class IsoNationality
	{
		static string DefaultNationality = "se";

		public static bool TryValidateOrSetDefault(string nationality, out string result)
		{
			if(String.IsNullOrWhiteSpace(nationality))
			{
				result = DefaultNationality;
				return true;
			}

			if(!TryValidate(nationality))
			{
				result = null;
				return false;
			}

			result = nationality.ToLowerInvariant();
			return true;
		}

		static bool TryValidate(string nationality)
		{
			return Regex.IsMatch(nationality, "^[a-z]{2}$", RegexOptions.IgnoreCase);
		}
	}
}
