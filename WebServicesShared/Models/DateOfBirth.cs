using System;
using System.Globalization;

namespace Accidis.WebServices.Models
{
	public sealed class DateOfBirth
	{
		public const string DateFormat = "yyMMdd";
		readonly DateTime _date;

		public DateOfBirth(string s)
		{
			_date = DateTime.ParseExact(s, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.AllowTrailingWhite);
		}

		public int Age => AgeOn(DateTime.Now);
		public int Day => _date.Day;
		public int Month => _date.Month;
		public int Year => _date.Year;

		public int AgeOn(DateTime date)
		{
			if(date.Month > Month || (date.Day >= Day && date.Month == Month))
				return date.Year - Year;
			return date.Year - Year - 1;
		}

		public string Format(string format)
		{
			return _date.ToString(format, CultureInfo.InvariantCulture);
		}

		public static bool IsValid(string dob)
		{
			DateTime ignored;
			return !string.IsNullOrEmpty(dob) && DateTime.TryParseExact(dob, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.AllowTrailingWhite, out ignored);
		}

		public override string ToString()
		{
			return _date.ToString(DateFormat, CultureInfo.InvariantCulture);
		}
	}
}