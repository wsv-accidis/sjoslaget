class BookingPaxItem {
	static const CABIN_TYPE_ID = 'CabinTypeId';
	static const REFERENCE = 'Reference';
	static const GROUP = 'Group';
	static const FIRST_NAME = 'FirstName';
	static const LAST_NAME = 'LastName';
	static const GENDER = 'Gender';
	static const DOB = 'Dob';
	static const NATIONALITY = 'Nationality';
	static const YEARS = 'Years';

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
			json[FIRST_NAME],
			json[LAST_NAME],
			json[GENDER],
			json[DOB],
			json[NATIONALITY],
			json[YEARS]
		);
	}
}
