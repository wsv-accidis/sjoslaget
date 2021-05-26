using System;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class SubCruiseCode
	{
		const string FirstValue = "A";
		const string SecondValue = "B";
		const string BothValue = FirstValue + SecondValue;

		public static readonly SubCruiseCode First = new SubCruiseCode(FirstValue);
		public static readonly SubCruiseCode Second = new SubCruiseCode(SecondValue);
		public static readonly SubCruiseCode Both = new SubCruiseCode(BothValue);
		readonly string _value;

		SubCruiseCode(string value)
		{
			_value = value;
		}

		public override bool Equals(object obj)
		{
			var other = obj as SubCruiseCode;
			return other != null && string.Equals(_value, other._value, StringComparison.Ordinal);
		}

		public static SubCruiseCode FromString(string s)
		{
			if(string.IsNullOrEmpty(s))
				throw new ArgumentNullException(nameof(s));

			switch(s.ToUpperInvariant())
			{
				case FirstValue:
					return First;
				case SecondValue:
					return Second;
				case BothValue:
					return Both;
				default:
					throw new ArgumentException("String does not describe a sub-cruise.", nameof(s));
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
