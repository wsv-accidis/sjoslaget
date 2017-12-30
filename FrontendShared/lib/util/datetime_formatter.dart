import 'package:intl/intl.dart' show DateFormat;

abstract class DateTimeFormatter {
	static final DateFormat _defaultFormat = new DateFormat('yyyy-MM-dd kk:mm');
	static final DateFormat _shortFormat = new DateFormat('yyyyMMdd');

	static String format(DateTime value) => _defaultFormat.format(value);

	static String formatShort(DateTime value) => _shortFormat.format(value);
}
