import 'dart:convert';

import 'package:decimal/decimal.dart';

class PaymentSummary {
	static const AMOUNT = 'Amount'; // for PaymentSource
	static const LATEST = 'Latest';
	static const TOTAL = 'Total';

	DateTime latest;
	Decimal total;

	PaymentSummary(this.latest, this.total);

	factory PaymentSummary.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new PaymentSummary.fromMap(map);
	}

	factory PaymentSummary.fromMap(Map<String, dynamic> json) {
		// TODO: JSON parser internally reads the decimal as a double. This may cause loss of precision although not very likely.
		return new PaymentSummary(
			DateTime.parse(json[LATEST]),
			Decimal.parse(json[TOTAL].toString())
		);
	}
}
