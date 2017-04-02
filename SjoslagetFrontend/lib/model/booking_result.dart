import 'dart:convert';

class BookingResult {
	static const REFERENCE = 'Reference';
	static const PASSWORD = 'Password';

	String reference;
	String password;

	BookingResult(this.reference, this.password);

	factory BookingResult.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new BookingResult(map[REFERENCE], map[PASSWORD]);
	}
}
