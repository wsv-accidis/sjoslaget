import 'dart:convert';

import 'json_field.dart';

class BookingDetails {
	String firstName;
	String lastName;
	String phoneNo;
	String email;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email);

	String toJson() {
		return JSON.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
		});
	}
}
