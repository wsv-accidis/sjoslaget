import 'dart:convert';

import 'json_field.dart';

class ExternalBooking {
	ExternalBooking(this.firstName, this.lastName, this.phoneNo, this.dob, this.specialRequest, this.type, this.paymentReceived);

	final String firstName;
	final String lastName;
	final String phoneNo;
	final String dob;
	final String specialRequest;
	final String type;
	final bool paymentReceived;

	String toJson() =>
		json.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			DOB: dob,
			SPECIAL_REQUEST: specialRequest,
			TYPE_ID: type,
			PAYMENT_RECEIVED: paymentReceived
		});
}
