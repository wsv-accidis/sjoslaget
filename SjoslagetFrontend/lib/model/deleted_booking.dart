import 'dart:convert';

import 'package:decimal/decimal.dart';

import 'json_field.dart';

class DeletedBooking {
	final String reference;
	final String firstName;
	final String lastName;
	final String phoneNo;
	final String email;
	final Decimal totalPrice;
	final Decimal amountPaid;
	final DateTime updated;
	final DateTime deleted;

	DeletedBooking(this.reference, this.firstName, this.lastName, this.phoneNo, this.email, this.totalPrice, this.amountPaid, this.updated, this.deleted);

	factory DeletedBooking.fromMap(Map<String, dynamic> map) {
		return new DeletedBooking(
			map[REFERENCE],
			map[FIRSTNAME],
			map[LASTNAME],
			map[PHONE_NO],
			map[EMAIL],
			map[TOTAL_PRICE],
			map[AMOUNT_PAID],
			map[UPDATED],
			map[DELETED]
		);
	}
}
