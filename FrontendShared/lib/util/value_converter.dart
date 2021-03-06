import 'package:decimal/decimal.dart';

abstract class ValueConverter {
	// The intended use for this is where a value gets internally parsed as double, but we want decimal.
	// This potentially causes a loss of precision and should be avoided if possible.
	static Decimal doubleToDecimal(double value) {
		if(!value.isFinite)
			return null;

		return Decimal.parse(value.toString());
	}

	static DateTime parseDateTime(String value) {
		if (null == value || value.isEmpty)
			return null;

		// Special case for DateTimes that came from .NET and can contain a fractional part of 7 digits
		if (value.contains(RegExp(r"\.[0-9]{7}$")))
			value = value.substring(0, value.length - 1);

		try {
			return DateTime.parse(value);
		} catch (e) {
			print('Exception parsing datetime: ${e.toString()}');
			return null;
		}
	}

	static Decimal parseDecimal(String value) {
		if (null == value || value.isEmpty)
			return null;

		try {
			return Decimal.parse(value.replaceAll(',', '.'));
		} catch (e) {
			print('Exception parsing decimal: ${e.toString()}');
			return null;
		}
	}

	static int toInt(dynamic id) {
		if (null == id)
			return 0;
		if (id is int)
			return id;
		if (id is double)
			return id.toInt();

		try {
			return int.parse(id.toString());
		} catch (e) {
			return 0;
		}
	}
}
