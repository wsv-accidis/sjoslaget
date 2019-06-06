import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class Payment {
	final Decimal amount;
	final DateTime created;

	Payment(this.amount, this.created);

	factory Payment.fromMap(Map<String, dynamic> json) =>
		Payment(
			ValueConverter.doubleToDecimal(json[AMOUNT]),
			DateTime.parse(json[CREATED])
		);
}
