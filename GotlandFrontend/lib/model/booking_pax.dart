import 'json_field.dart';

class BookingPax {
	final String firstName;
	final String lastName;
	final String gender;
	final String dob;
	final String food;
	final int cabinClassMin;
	final int cabinClassPreferred;
	final int cabinClassMax;

	BookingPax(this.firstName, this.lastName, this.gender, this.dob, this.food, this.cabinClassMin, this.cabinClassPreferred, this.cabinClassMax);

	factory BookingPax.fromMap(Map<String, dynamic> map) =>
		BookingPax(
			map[FIRSTNAME],
			map[LASTNAME],
			map[GENDER],
			map[DOB],
			map[FOOD],
			map[CABIN_CLASS_MIN],
			map[CABIN_CLASS_PREF],
			map[CABIN_CLASS_MAX],
		);

	Map<String, dynamic> toMap() =>
		<String, dynamic>{
			FIRSTNAME: firstName,
			LASTNAME: lastName,
			GENDER: gender,
			DOB: dob,
			FOOD: food,
			CABIN_CLASS_MIN: cabinClassMin,
			CABIN_CLASS_PREF: cabinClassPreferred,
			CABIN_CLASS_MAX: cabinClassMax
		};
}
