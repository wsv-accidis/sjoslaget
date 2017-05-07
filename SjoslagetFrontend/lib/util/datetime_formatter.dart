import 'package:intl/intl.dart' show DateFormat;

abstract class DateTimeFormatter {
	static final DateFormat _defaultFormat = new DateFormat('yyyy-MM-dd kk:mm');

	static String format(DateTime value) => _defaultFormat.format(value);
}
