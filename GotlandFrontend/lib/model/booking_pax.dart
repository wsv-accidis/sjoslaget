import 'json_field.dart';

class BookingPax {
	final String firstName;
	final String lastName;
	final String gender;
	final String dob;
	final int cabinClassMin;
	final int cabinClassPreferred;
	final int cabinClassMax;
	final String specialRequest;

	BookingPax(this.firstName, this.lastName, this.gender, this.dob, this.cabinClassMin, this.cabinClassPreferred, this.cabinClassMax, this.specialRequest);

	factory BookingPax.fromMap(Map<String, dynamic> map) =>
		BookingPax(
			map[FIRSTNAME],
			map[LASTNAME],
			map[GENDER],
			map[DOB],
			map[CABIN_CLASS_MIN],
			map[CABIN_CLASS_PREF],
			map[CABIN_CLASS_MAX],
			map[SPECIAL_REQUEST]
		);

	Map<String, dynamic> toMap() =>
		<String, dynamic>{
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			GENDER: gender,
			DOB: dob,
			CABIN_CLASS_MIN: cabinClassMin,
			CABIN_CLASS_PREF: cabinClassPreferred,
			CABIN_CLASS_MAX: cabinClassMax,
			SPECIAL_REQUEST: specialRequest
		};
}
