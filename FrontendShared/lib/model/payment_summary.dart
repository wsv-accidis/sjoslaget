import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../util/value_converter.dart';
import 'json_field.dart';

class PaymentSummary {
	final DateTime latest;
	final Decimal total;

	PaymentSummary(this.latest, this.total);

	factory PaymentSummary.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return PaymentSummary.fromMap(map);
	}

	factory PaymentSummary.fromMap(Map<String, dynamic> json) =>
		PaymentSummary(
			DateTime.parse(json[LATEST]),
			ValueConverter.doubleToDecimal(json[TOTAL])
		);
}
