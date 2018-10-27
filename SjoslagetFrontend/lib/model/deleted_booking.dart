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

	factory DeletedBooking.fromMap(Map<String, dynamic> map) =>
		DeletedBooking(
			map[REFERENCE],
			map[FIRSTNAME],
			map[LASTNAME],
			map[PHONE_NO],
			map[EMAIL],
			Decimal.parse(map[TOTAL_PRICE].toString()),
			Decimal.parse(map[AMOUNT_PAID].toString()),
			DateTime.parse(map[UPDATED]),
			DateTime.parse(map[DELETED])
		);
}
