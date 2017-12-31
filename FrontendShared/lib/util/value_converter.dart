abstract class ValueConverter {
	static DateTime parseDateTime(String value) {
		if (null == value || value.isEmpty)
			return null;

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
