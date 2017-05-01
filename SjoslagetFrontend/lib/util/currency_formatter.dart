import 'package:intl/intl.dart' show NumberFormat;

import 'package:decimal/decimal.dart';

abstract class CurrencyFormatter {
	static final NumberFormat _numberFormat = new NumberFormat('#,### kr', 'sv_SE');
	static final NumberFormat _numberFormatDecimal = new NumberFormat('#,###.00 kr', 'sv_SE');
	static final NumberFormat _numberFormatInput = new NumberFormat('0', 'sv_SE');
	static final NumberFormat _numberFormatInputDecimal = new NumberFormat('0.00', 'sv_SE');

	static String formatIntAsSEK(int value) {
		return _numberFormat.format(value);
	}

	static String formatDecimalAsSEK(Decimal value) {
		if (_hasDecimalDigits(value))
			return _numberFormatDecimal.format(value.toDouble());
		else
			return _numberFormat.format(value.toDouble());
	}

	static String formatDecimalForInput(Decimal value) {
		if (_hasDecimalDigits(value))
			return _numberFormatInputDecimal.format(value.toDouble());
		else
			return _numberFormatInput.format(value.toDouble());
	}

	static bool _hasDecimalDigits(Decimal value) {
		return value.toDouble() != value.floorToDouble();
	}
}
