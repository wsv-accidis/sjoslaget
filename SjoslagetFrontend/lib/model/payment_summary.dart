import 'dart:convert';

import 'package:decimal/decimal.dart';

import 'json_field.dart';

class PaymentSummary {
	DateTime latest;
	Decimal total;

	PaymentSummary(this.latest, this.total);

	factory PaymentSummary.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return PaymentSummary.fromMap(map);
	}

	// TODO: JSON parser internally reads the decimal as a double. This may cause loss of precision although not very likely.
	factory PaymentSummary.fromMap(Map<String, dynamic> json) =>
		PaymentSummary(
			DateTime.parse(json[LATEST]),
			Decimal.parse(json[TOTAL].toString())
		);
}
