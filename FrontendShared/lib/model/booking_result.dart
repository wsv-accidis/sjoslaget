import 'dart:convert';

import 'json_field.dart';

class BookingResult {
	String reference;
	String password;

	BookingResult(this.reference, this.password);

	factory BookingResult.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return new BookingResult(map[REFERENCE], map[PASSWORD]);
	}
}
