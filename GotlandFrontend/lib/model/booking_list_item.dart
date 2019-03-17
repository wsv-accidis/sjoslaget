import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/booking_payment_model.dart';

import 'booking_allocation_model.dart';
import 'json_field.dart';

class BookingListItem {
	final String reference;
	final String teamName;
	final String firstName;
	final String lastName;
	final int numberOfPax;
	final int queueNo;
	final DateTime updated;

	final BookingAllocationModel allocation;
	final BookingPaymentModel payment;

	BookingListItem(this.reference, this.teamName, this.firstName, this.lastName, this.numberOfPax, this.queueNo, this.updated, this.allocation, this.payment);

	factory BookingListItem.fromMap(Map<String, dynamic> json) =>
		BookingListItem(
			json[REFERENCE],
			json[TEAM_NAME],
			json[FIRSTNAME],
			json[LASTNAME],
			json[NUMBER_OF_PAX],
			json[QUEUE_NO],
			DateTime.parse(json[UPDATED]),
			BookingAllocationModel(
				json[NUMBER_OF_PAX],
				json[ALLOCATED_PAX]
			),
			BookingPaymentModel(
				Decimal.parse(json[TOTAL_PRICE].toString()),
				Decimal.parse(json[AMOUNT_PAID].toString())
			)
		);
}
