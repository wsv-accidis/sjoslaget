import 'json_field.dart';

class BookingPaxListItem {
	final String reference;
	final String teamName;
	final String firstName;
	final String lastName;
	final String gender;
	final String dob;
	final int cabinClassMin;
	final int cabinClassPreferred;
	final int cabinClassMax;

	BookingPaxListItem(this.reference, this.teamName, this.firstName, this.lastName, this.gender, this.dob, this.cabinClassMin, this.cabinClassPreferred, this.cabinClassMax);

	factory BookingPaxListItem.fromMap(Map<String, dynamic> json) =>
		BookingPaxListItem(
			json[REFERENCE],
			json[TEAM_NAME],
			json[FIRSTNAME],
			json[LASTNAME],
			json[GENDER],
			json[DOB],
			json[CABIN_CLASS_MIN],
			json[CABIN_CLASS_PREF],
			json[CABIN_CLASS_MAX]
		);
}
