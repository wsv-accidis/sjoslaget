import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class ExternalBooking {
	ExternalBooking(this.id, this.firstName, this.lastName, this.phoneNo, this.dob, this.specialRequest, this.type, this.paymentReceived, this.paymentConfirmed, this.created);

	final String id;
	final String firstName;
	final String lastName;
	final String phoneNo;
	final String dob;
	final String specialRequest;
	final String type;
	final bool paymentReceived;
	final bool paymentConfirmed;
	final DateTime created;

	factory ExternalBooking.fromMap(Map<String, dynamic> json) =>
		ExternalBooking(
			json[ID],
			json[FIRSTNAME],
			json[LASTNAME],
			json[PHONE_NO],
			json[DOB],
			json[SPECIAL_REQUEST],
			json[TYPE_ID],
			json[PAYMENT_RECEIVED],
			json[PAYMENT_CONFIRMED],
			ValueConverter.parseDateTime(json[CREATED])
		);
}
