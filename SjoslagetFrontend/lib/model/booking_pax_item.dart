import 'json_field.dart';

class BookingPaxItem {
	String cabinType;
	final String cabinTypeId;
	final String reference;
	String group;
	final String firstName;
	final String lastName;
	final String gender;
	final String dob;
	final String nationality;
	final int years;

	String get name => firstName + ' ' + lastName;

	BookingPaxItem(this.cabinTypeId, this.reference, this.group, this.firstName, this.lastName, this.gender, this.dob, this.nationality, this.years);

	factory BookingPaxItem.fromMap(Map<String, dynamic> json) {
		return new BookingPaxItem(
			json[CABIN_TYPE_ID],
			json[REFERENCE],
			json[GROUP],
			json[FIRSTNAME],
			json[LASTNAME],
			json[GENDER],
			json[DOB],
			json[NATIONALITY],
			json[YEARS]
		);
	}
}
