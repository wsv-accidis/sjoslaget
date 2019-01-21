import 'dart:convert';

import 'booking_pax.dart';
import 'json_field.dart';

class BookingSource {
	String reference;
	String firstName;
	String lastName;
	String email;
	String phoneNo;
	String teamName;
	String specialRequest;
	List<BookingPax> pax;

	BookingSource(this.reference, this.firstName, this.lastName, this.email, this.phoneNo, this.teamName, this.specialRequest, this.pax);

	factory BookingSource.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);

		final List<BookingPax> pax = map[PAX]
			.map((dynamic value) => BookingPax.fromMap(value))
			.cast<BookingPax>()
			.toList(growable: false);

		return BookingSource(
			map[REFERENCE],
			map[FIRSTNAME],
			map[LASTNAME],
			map[EMAIL],
			map[PHONE_NO],
			map[TEAM_NAME],
			map[SPECIAL_REQUEST],
			pax
		);
	}

	String toJson() {
		final paxMap = pax.map((p) => p.toMap()).toList(growable: false);

		return json.encode({
			REFERENCE: reference,
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			EMAIL: email,
			PHONE_NO: phoneNo,
			TEAM_NAME: teamName,
			SPECIAL_REQUEST: specialRequest,
			PAX: paxMap
		});
	}
}
