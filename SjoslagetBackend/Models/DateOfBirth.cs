﻿using System;
using System.Globalization;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class DateOfBirth
	{
		const string DateFormat = "yyMMdd";
		readonly DateTime _date;

		public DateOfBirth(string s)
		{
			_date = DateTime.ParseExact(s, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None);
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

		public static bool IsValid(string dob)
		{
			DateTime ignored;
			return !String.IsNullOrEmpty(dob) && DateTime.TryParseExact(dob, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out ignored);
		}

		public override string ToString()
		{
			return _date.ToString(DateFormat, CultureInfo.InvariantCulture);
		}
	}
}
