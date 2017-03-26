import 'dart:convert';

import 'booking_cabin.dart';

class BookingDetails {
	static const CABINS = 'Cabins';
	static const EMAIL = 'Email';
	static const FIRSTNAME = 'FirstName';
	static const LASTNAME = 'LastName';
	static const LUNCH = 'Lunch';
	static const PHONE_NO = 'PhoneNo';

	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String lunch;

	BookingDetails(this.firstName, this.lastName, this.phoneNo, this.email, this.lunch);

	String toJson([List<BookingCabin> cabins = null]) {
		final cabinsMap = null == cabins ? null : cabins.map((c) => c.toMap()).toList(growable: false);
		return JSON.encode({
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			PHONE_NO: phoneNo,
			EMAIL: email,
			LUNCH: lunch,
			CABINS: cabinsMap
		});
	}

	BookingDetails.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		firstName = map[FIRSTNAME];
		lastName = map[LASTNAME];
		phoneNo = map[PHONE_NO];
		email = map[EMAIL];
		lunch = map[LUNCH];
	}
}
