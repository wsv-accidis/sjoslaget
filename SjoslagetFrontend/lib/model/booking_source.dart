import 'dart:convert';

import 'booking_cabin.dart';
import 'booking_details.dart';
import 'payment_summary.dart';

class BookingSource extends BookingDetails {
	static const CABINS = 'Cabins';
	static const DISCOUNT = 'Discount';
	static const IS_LOCKED = 'IsLocked';
	static const PAYMENT = 'Payment';

	List<BookingCabin> cabins;
	int discount;
	bool isLocked;
	PaymentSummary payment;

	BookingSource(String firstName, String lastName, String phoneNo, String email, String lunch, String reference, this.discount, this.isLocked, this.cabins, this.payment)
		: super(firstName, lastName, phoneNo, email, lunch, reference) {
	}

	BookingSource.fromDetails(BookingDetails details, this.cabins)
		: super(details.firstName, details.lastName, details.phoneNo, details.email, details.lunch, details.reference) {
	}

	factory BookingSource.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		final List<BookingCabin> cabins = map[CABINS].map((Map<String, dynamic> value) => new BookingCabin.fromMap(value)).toList(growable: false);

		return new BookingSource(
			map[BookingDetails.FIRSTNAME],
			map[BookingDetails.LASTNAME],
			map[BookingDetails.PHONE_NO],
			map[BookingDetails.EMAIL],
			map[BookingDetails.LUNCH],
			map[BookingDetails.REFERENCE],
			map[DISCOUNT],
			map[IS_LOCKED],
			cabins,
			new PaymentSummary.fromMap(map[PAYMENT])
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
