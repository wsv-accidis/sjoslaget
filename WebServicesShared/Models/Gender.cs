﻿using System;

namespace Accidis.WebServices.Models
{
	public class Gender
	{
		const string FemaleValue = "f";
		const string MaleValue = "m";
		const string OtherValue = "x";
		const string NoneValue = "-";

		public static readonly Gender Female = new Gender(FemaleValue);
		public static readonly Gender Male = new Gender(MaleValue);
		public static readonly Gender Other = new Gender(OtherValue);
		public static readonly Gender None = new Gender(NoneValue);
		readonly string _value;

		Gender(string value)
		{
			_value = value;
		}

		public override bool Equals(object obj)
		{
			var other = obj as Gender;
			return other != null && String.Equals(_value, other._value, StringComparison.Ordinal);
		}

		public static Gender FromString(string s)
		{
			if(String.IsNullOrEmpty(s))
				throw new ArgumentNullException(nameof(s));

			switch(s.ToLowerInvariant())
			{
				case MaleValue:
					return Male;
				case FemaleValue:
					return Female;
				case OtherValue:
					return Other;
				case NoneValue:
					return None;
				default:
					throw new ArgumentException("String does not describe a gender.", nameof(s));
			}
		}

		public override int GetHashCode()
		{
			return _value?.GetHashCode() ?? 0;
		}

		public override string ToString()
		{
			return _value;
		}
	}
}
