
abstract class ValueConverter {
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
