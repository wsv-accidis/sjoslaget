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

	factory BookingDetails.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new BookingDetails(map[FIRSTNAME], map[LASTNAME], map[PHONE_NO], map[EMAIL], map[LUNCH]);
	}

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

}
