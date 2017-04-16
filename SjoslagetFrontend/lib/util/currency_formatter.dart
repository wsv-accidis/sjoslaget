import 'package:intl/intl.dart' show NumberFormat;

abstract class CurrencyFormatter {
	static final NumberFormat _numberFormat = new NumberFormat('#,###.## kr', 'sv_SE');

	static String formatIntAsSEK(int value) {
		return _numberFormat.format(value);
	}
}
