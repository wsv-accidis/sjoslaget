abstract class ValueConverter {
	static DateTime parseDateTime(String value) {
		if (null == value || value.isEmpty)
			return null;

		// Special case for DateTimes that came from .NET and can contain a fractional part of 7 digits
		if (value.contains(RegExp(r"\.[0-9]{7}$")))
			value = value.substring(0, value.length - 1);

		return DateTime.parse(value);
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
