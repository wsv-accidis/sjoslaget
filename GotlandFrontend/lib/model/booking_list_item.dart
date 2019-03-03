import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/booking_payment_model.dart';

import 'json_field.dart';

class BookingListItem extends BookingPaymentModel {
	final String reference;
	final String teamName;
	final String firstName;
	final String lastName;
	final int numberOfPax;
	final int queueNo;
	final DateTime updated;

	BookingListItem(this.reference, this.teamName, this.firstName, this.lastName, Decimal totalPrice, Decimal amountPaid, this.numberOfPax, this.queueNo, this.updated)
		: super(totalPrice, amountPaid);

	factory BookingListItem.fromMap(Map<String, dynamic> json) =>
		BookingListItem(
			json[REFERENCE],
			json[TEAM_NAME],
			json[FIRSTNAME],
			json[LASTNAME],
			Decimal.parse(json[TOTAL_PRICE].toString()),
			Decimal.parse(json[AMOUNT_PAID].toString()),
			json[NUMBER_OF_PAX],
			json[QUEUE_NO],
			DateTime.parse(json[UPDATED])
		);
}
