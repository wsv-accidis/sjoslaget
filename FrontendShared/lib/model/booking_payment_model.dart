import 'package:decimal/decimal.dart';

class BookingPaymentModel {
	static const String STATUS_NONE = 'none';
	static const String STATUS_FULLY_PAID = 'fully-paid';
	static const String STATUS_PARTIALLY_PAID = 'partially-paid';
	static const String STATUS_OVER_PAID = 'over-paid';
	static const String STATUS_NOT_PAID = 'not-paid';

	final Decimal totalPrice;
	final Decimal amountPaid;

	BookingPaymentModel(this.totalPrice, this.amountPaid);

	Decimal get amountRemaining => totalPrice - amountPaid;

	bool get hasPrice => totalPrice.toDouble() > 0;

	bool get isFullyPaid => hasPrice && amountRemaining.ceilToDouble() == 0;

	bool get isPartiallyPaid => hasPrice && amountRemaining.toDouble() > 0 && amountRemaining < totalPrice;

	bool get isOverPaid => hasPrice && amountRemaining.toDouble() < 0;

	bool get isUnpaid => hasPrice && amountPaid.toDouble() <= 0;

	String get status {
		if (isFullyPaid)
			return STATUS_FULLY_PAID;
		if (isPartiallyPaid)
			return STATUS_PARTIALLY_PAID;
		if (isOverPaid)
			return STATUS_OVER_PAID;
		if (isUnpaid)
			return STATUS_NOT_PAID;

		return STATUS_NONE;
	}

	int get statusAsInt {
		if (isFullyPaid)
			return 3;
		if (isPartiallyPaid)
			return 2;
		if (isOverPaid)
			return 1;
		if (isUnpaid)
			return 0;

		return 999;
	}
}
