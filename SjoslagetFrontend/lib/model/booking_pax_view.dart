import 'package:quiver/strings.dart' as str show isBlank, isEmpty;

import '../model/booking_pax.dart';

class BookingPaxView {
	String group;
	String groupError;
	String firstName;
	String firstNameError;
	String lastName;
	String lastNameError;
	String gender;
	bool genderError;
	String dob;
	String dobError;
	String nationality;
	String nationalityError;
	String years;
	String yearsError;

	bool firstRow;
	bool requiredRow;

	BookingPaxView() {
		// TODO: Would be better not to set default gender but material-radio is not sending a checkedChange event if unset
		gender = 'm';
	}

	BookingPaxView.fromBookingPax(BookingPax pax) {
		group = pax.group;
		firstName = pax.firstName;
		lastName = pax.lastName;
		gender = pax.gender;
		dob = pax.dob;
		nationality = pax.nationality;
		years = pax.years.toString();
		clearErrors();
	}

	bool get hasError => hasGroupError || hasFirstNameError || hasLastNameError || hasGenderError || hasDobError || hasNationalityError || hasYearsError;

	bool get hasGroupError => !str.isEmpty(groupError);

	bool get hasFirstNameError => !str.isEmpty(firstNameError);

	bool get hasLastNameError => !str.isEmpty(lastNameError);

	bool get hasGenderError => str.isEmpty(gender);

	bool get hasDobError => !str.isEmpty(dobError);

	bool get hasNationalityError => !str.isEmpty(nationalityError);

	bool get hasYearsError => !str.isEmpty(yearsError);

	bool get isEmpty => str.isBlank(group) && str.isBlank(firstName) && str.isBlank(lastName) && str.isBlank(dob);

	void clearErrors() {
		groupError = null;
		firstNameError = null;
		lastNameError = null;
		genderError = false;
		dobError = null;
		nationalityError = null;
		yearsError = null;
	}

	BookingPax toBookingPax() {
		return new BookingPax(
			group,
			firstName,
			lastName,
			gender,
			dob,
			nationality,
			_toInt(years));
	}

	static int _toInt(id) {
		if (null == id) return 0;
		return int.parse(id.toString());
	}
}
