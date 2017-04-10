import 'dart:convert';

import 'booking_cabin.dart';
import 'booking_details.dart';

class BookingSource extends BookingDetails {
	static const CABINS = 'Cabins';

	List<BookingCabin> cabins;

	BookingSource(String firstName, String lastName, String phoneNo, String email, String lunch, String reference, this.cabins)
		: super(firstName, lastName, phoneNo, email, lunch, reference) {
	}

	BookingSource.fromDetails(BookingDetails details, this.cabins)
		: super(details.firstName, details.lastName, details.phoneNo, details.email, details.lunch, details.reference) {
	}

	factory BookingSource.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		final List<BookingCabin> cabins = map[CABINS].map((value) => new BookingCabin.fromMap(value)).toList(growable: false);

		return new BookingSource(
			map[BookingDetails.FIRSTNAME],
			map[BookingDetails.LASTNAME],
			map[BookingDetails.PHONE_NO],
			map[BookingDetails.EMAIL],
			map[BookingDetails.LUNCH],
			map[BookingDetails.REFERENCE],
			cabins
		);
	}

	String toJson() {
		final cabinsMap = null == cabins ? null : cabins.map((c) => c.toMap()).toList(growable: false);
		return JSON.encode({
			BookingDetails.FIRSTNAME: firstName,
			BookingDetails.LASTNAME: lastName,
			BookingDetails.PHONE_NO: phoneNo,
			BookingDetails.EMAIL: email,
			BookingDetails.LUNCH: lunch,
			BookingDetails.REFERENCE: reference,
			CABINS: cabinsMap
		});
	}
}
