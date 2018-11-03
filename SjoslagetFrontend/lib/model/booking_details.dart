import 'dart:convert';

import 'json_field.dart';

class BookingDetails {
	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String lunch;
	String reference;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email, this.lunch, this.reference);

	factory BookingDetails.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return BookingDetails(map[FIRSTNAME], map[LASTNAME], map[PHONE_NO], map[EMAIL], map[LUNCH], map[REFERENCE]);
	}

	String toJson() =>
		json.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			LUNCH: lunch,
			REFERENCE: reference
		});
}
