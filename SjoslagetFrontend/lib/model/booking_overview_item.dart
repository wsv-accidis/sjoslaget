import 'package:decimal/decimal.dart';
import 'package:quiver/strings.dart' as str show isEmpty;

import 'json_field.dart';

class BookingOverviewItem {
	final String reference;
	final String firstName;
	final String lastName;
	final String lunch;
	final Decimal totalPrice;
	final Decimal amountPaid;
	final int numberOfCabins;
	final bool isLocked;
	final DateTime updated;

	Decimal get amountRemaining => totalPrice - amountPaid;

	bool get isFullyPaid => amountRemaining.ceilToDouble() == 0;

	bool get isPartiallyPaid => amountRemaining.toDouble() > 0 && amountRemaining < totalPrice;

	bool get isOverPaid => amountRemaining.toDouble() < 0;

	bool get isUnpaid => amountPaid.toDouble() <= 0;

	String get lunchFormatted => str.isEmpty(lunch) ? '' : lunch + ':00';

	BookingOverviewItem(this.reference, this.firstName, this.lastName, this.lunch, this.totalPrice, this.amountPaid, this.numberOfCabins, this.isLocked, this.updated);

	factory BookingOverviewItem.fromMap(Map<String, dynamic> json) {
		return new BookingOverviewItem(
			json[REFERENCE],
			json[FIRSTNAME],
			json[LASTNAME],
			json[LUNCH],
			Decimal.parse(json[TOTAL_PRICE].toString()),
			Decimal.parse(json[AMOUNT_PAID].toString()),
			json[NUMBER_OF_CABINS],
			json[IS_LOCKED],
			DateTime.parse(json[UPDATED])
		);
	}
}
