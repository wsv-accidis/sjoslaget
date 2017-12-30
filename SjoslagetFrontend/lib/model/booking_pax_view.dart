import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' as str show isBlank, isEmpty, isNotEmpty;

import '../model/booking_pax.dart';

class BookingPaxView {
	String group;
	String groupError;
	String firstName;
	String firstNameError;
	String lastName;
	String lastNameError;
	String gender;
	bool genderError = false;
	String dob;
	String dobError;
	String nationality;
	String nationalityError;
	String years;
	String yearsError;

	bool firstRow = false;
	bool requiredRow = false;

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

	bool get hasGroupError => str.isNotEmpty(groupError);

	bool get hasFirstNameError => str.isNotEmpty(firstNameError);

	bool get hasLastNameError => str.isNotEmpty(lastNameError);

	bool get hasGenderError => str.isEmpty(gender);

	bool get hasDobError => str.isNotEmpty(dobError);

	bool get hasNationalityError => str.isNotEmpty(nationalityError);

	bool get hasYearsError => str.isNotEmpty(yearsError);

	bool get isEmpty => str.isBlank(group) && str.isBlank(firstName) && str.isBlank(lastName) && str.isBlank(dob);

	bool get isValid => !hasGroupError && !hasFirstNameError && !hasLastNameError && !hasGenderError && !hasDobError && !hasNationalityError && !hasYearsError;

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

	static int _toInt(dynamic id) => ValueConverter.toInt(id);
}
