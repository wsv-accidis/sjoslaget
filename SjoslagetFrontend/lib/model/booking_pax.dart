import 'package:quiver/strings.dart' as str show isBlank;

class BookingPax {
	final String group;
	final String firstName;
	final String lastName;
	final String gender;
	final String dob;
	final String nationality;
	final int years;

	BookingPax(this.group, this.firstName, this.lastName, this.gender, this.dob, this.nationality, this.years);

	bool get isEmpty => str.isBlank(group) && str.isBlank(firstName) && str.isBlank(lastName) && str.isBlank(dob);
}
