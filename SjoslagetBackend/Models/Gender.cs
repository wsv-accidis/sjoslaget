using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public enum Gender
	{
		Female,
		Male,
		Other
	}

	static class GenderConvert
	{
		const string Female = "f";
		const string Male = "m";
		const string Other = "x";

		public static Gender FromString(string s)
		{
			if(String.IsNullOrEmpty(s))
				throw new ArgumentNullException(nameof(s));

			switch(s.ToLowerInvariant())
			{
				case Male:
					return Gender.Male;
				case Female:
					return Gender.Female;
				case Other:
					return Gender.Other;
				default:
					throw new ArgumentException("String does not describe a gender.", nameof(s));
			}
		}

		public static string ToString(Gender g)
		{
			switch(g)
			{
				case Gender.Male:
					return Male;
				case Gender.Female:
					return Female;
				case Gender.Other:
					return Other;
				default:
					throw new ArgumentException("Enum value does not describe a gender.", nameof(g));
			}
		}
	}
}
