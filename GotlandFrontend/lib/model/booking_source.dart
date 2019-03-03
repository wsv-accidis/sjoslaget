import 'dart:convert';

import 'package:frontend_shared/model.dart' show PaymentSummary;
import 'package:frontend_shared/util/value_converter.dart';

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
	int discount;
	DateTime confirmationSent;
	List<BookingPax> pax;
	PaymentSummary payment;

	BookingSource(this.reference, this.firstName, this.lastName, this.email, this.phoneNo, this.teamName, this.specialRequest, this.discount, this.confirmationSent, this.pax, this.payment);

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
			map[DISCOUNT],
			ValueConverter.parseDateTime(map[CONFIRMATION_SENT]),
			pax,
			PaymentSummary.fromMap(map[PAYMENT])
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
