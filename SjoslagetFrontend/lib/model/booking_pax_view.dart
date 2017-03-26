import 'package:quiver/strings.dart' as str show isBlank, isEmpty;

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
}
