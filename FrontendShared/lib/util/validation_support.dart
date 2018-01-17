class ValidationSupport {
	static final _dobRegExp = new RegExp(r'^\d{6}$');
	static final _nationalityRegExp = new RegExp(r'^[a-zA-Z]{2}$');
	static final _numberRegExp = new RegExp(r'^\d+$');

	static bool isDateOfBirth(String value) {
		return _dobRegExp.hasMatch(value) && _isValidDate(value);
	}

	static bool isTwoLetterNationality(String value) {
		return _nationalityRegExp.hasMatch(value);
	}

	static bool isSimpleInteger(String value) {
		return _numberRegExp.hasMatch(value);
	}

	// Mildly dubious conversion - interpret as 20xx unless that would be in the future, otherwise 19xx
	static bool _isLeapYear(int twoDigitYear) {
		final int thisYear = (new DateTime.now()).year;
		final int year = 2000 + twoDigitYear > thisYear ? 1900 + twoDigitYear : 2000 + twoDigitYear;
		return 0 == year % 4 && (0 != year % 100 || 0 == year % 400);
	}

	// Dart's DateFormat doesn't do very good validation of dates so we use this simple version
	static bool _isValidDate(String dob) {
		final twoDigitYear = int.parse(dob.substring(0, 2));
		final month = int.parse(dob.substring(2, 4));
		final day = int.parse(dob.substring(4, 6));

		int maxDay;
		if ([1, 3, 5, 7, 8, 10, 12].contains(month)) { // jan, mar, may, jul, aug, oct, dec
			maxDay = 31;
		} else if ([4, 6, 9, 11].contains(month)) { // apr, jun, sept, nov
			maxDay = 30;
		} else if (2 == month) { // feb
			maxDay = _isLeapYear(twoDigitYear) ? 29 : 28;
		} else {
			return false;
		}

		if (day < 1 || day > maxDay) {
			return false;
		}

		return true;
	}
}
