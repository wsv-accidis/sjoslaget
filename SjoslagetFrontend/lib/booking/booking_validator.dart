import 'package:quiver/strings.dart' show isBlank;

import 'package:angular2/core.dart';

import '../model/booking_cabin_view.dart';
import '../model/booking_pax_view.dart';

@Injectable()
class BookingValidator {
	final _dobRegExp = new RegExp(r"^\d{6}$");
	final _nationalityRegExp = new RegExp(r"^[a-zA-Z]{2}$");
	final _yearsRegExp = new RegExp(r"\d+");

	bool validateCabin(BookingCabinView cabin) {
		cabin.isValid = cabin.pax
			.where((p) => !validatePax(p))
			.isEmpty;

		return cabin.isValid;
	}

	bool validatePax(BookingPaxView pax) {
		if (!pax.requiredRow && !pax.firstRow && pax.isEmpty) {
			pax.clearErrors();
			return true;
		}

		if (pax.firstRow && isBlank(pax.group)) {
			pax.groupError = "Ange förening.";
		} else {
			pax.groupError = null;
		}

		if (isBlank(pax.firstName)) {
			pax.firstNameError = "Ange förnamn.";
		} else {
			pax.firstNameError = null;
		}

		if (isBlank(pax.lastName)) {
			pax.lastNameError = "Ange efternamn.";
		} else {
			pax.lastNameError = null;
		}

		if (isBlank(pax.dob)) {
			pax.dobError = "Ange födelsedatum.";
		} else if (!_isValidDate(pax.dob)) {
			pax.dobError = "Ange ett giltigt datum.";
		} else {
			pax.dobError = null;
		}

		if (!isBlank(pax.nationality) && !_nationalityRegExp.hasMatch(pax.nationality)) {
			pax.nationalityError = "Ange en landskod från listan.";
		} else {
			pax.nationalityError = null;
		}

		if (!isBlank(pax.years) && !_yearsRegExp.hasMatch(pax.years)) {
			pax.yearsError = "Ange siffror.";
		} else {
			pax.yearsError = null;
		}

		return !pax.hasError;
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
