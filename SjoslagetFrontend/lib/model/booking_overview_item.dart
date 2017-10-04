import 'package:decimal/decimal.dart';

import 'booking_dashboard_item.dart';

class BookingOverviewItem {
	static const AMOUNT_PAID = 'AmountPaid';
	static const IS_LOCKED = 'IsLocked';
	static const TOTAL_PRICE = 'TotalPrice';

	final String reference;
	final String firstName;
	final String lastName;
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

	BookingOverviewItem(this.reference, this.firstName, this.lastName, this.totalPrice, this.amountPaid, this.numberOfCabins, this.isLocked, this.updated);

	factory BookingOverviewItem.fromMap(Map<String, dynamic> json) {
		return new BookingOverviewItem(
			json[BookingDashboardItem.REFERENCE],
			json[BookingDashboardItem.FIRSTNAME],
			json[BookingDashboardItem.LASTNAME],
			Decimal.parse(json[TOTAL_PRICE].toString()),
			Decimal.parse(json[AMOUNT_PAID].toString()),
			json[BookingDashboardItem.NUMBER_OF_CABINS],
			json[IS_LOCKED],
			DateTime.parse(json[BookingDashboardItem.UPDATED])
		);
	}
}
