import 'package:quiver/strings.dart' as str show isBlank, isEmpty;

class BookingPaxView {
	static RegExp _dobRegExp = new RegExp(r"^\d{6}$");
	static RegExp _nationalityRegExp = new RegExp(r"^[a-zA-Z]{2}$");
	static RegExp _yearsRegExp = new RegExp(r"\d+");

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
		gender = "m";
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

	bool validate() {
		if (!requiredRow && !firstRow && isEmpty) {
			_clearErrors();
			return true;
		}

		if (firstRow && str.isBlank(group)) {
			groupError = "Ange förening.";
		} else {
			groupError = null;
		}

		if (str.isBlank(firstName)) {
			firstNameError = "Ange förnamn.";
		} else {
			firstNameError = null;
		}

		if (str.isBlank(lastName)) {
			lastNameError = "Ange efternamn.";
		} else {
			lastNameError = null;
		}

		if (str.isBlank(dob)) {
			dobError = "Ange födelsedatum.";
		} else if (!_isValidDate(dob)) {
			dobError = "Ange ett giltigt datum.";
		} else {
			dobError = null;
		}

		if (!str.isBlank(nationality) && !_nationalityRegExp.hasMatch(nationality)) {
			nationalityError = "Ange en landskod från listan.";
		} else {
			nationalityError = null;
		}

		if (!str.isBlank(years) && !_yearsRegExp.hasMatch(years)) {
			yearsError = "Ange siffror.";
		} else {
			yearsError = null;
		}

		return !hasError;
	}

	void _clearErrors() {
		groupError = null;
		firstNameError = null;
		lastNameError = null;
		genderError = false;
		dobError = null;
		nationalityError = null;
		yearsError = null;
	}

	// TODO: Dart's DateFormat doesn't do very good validation of dates so we use this simple version for now
	bool _isValidDate(String dob) {
		if (!_dobRegExp.hasMatch(dob)) {
			return false;
		}

		final month = int.parse(dob.substring(2, 4));
		final day = int.parse(dob.substring(4, 6));

		int maxDay;
		if ([1, 3, 5, 7, 8, 10, 12].contains(month)) { // jan, mar, may, jul, aug, oct, dec
			maxDay = 31;
		} else if ([4, 6, 9, 11].contains(month)) { // apr, jun, sept, nov
			maxDay = 30;
		} else if (2 == month) { // feb (don't bother with leap years)
			maxDay = 29;
		} else {
			return false;
		}

		if (day < 1 || day > maxDay) {
			return false;
		}

		return true;
	}
}
