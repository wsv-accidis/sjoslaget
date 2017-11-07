import 'package:quiver/strings.dart' show isBlank;

import 'package:angular/angular.dart';

import '../model/booking_cabin_view.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_product_view.dart';

@Injectable()
class BookingValidator {
	final _dobRegExp = new RegExp(r'^\d{6}$');
	final _nationalityRegExp = new RegExp(r'^[a-zA-Z]{2}$');
	final _numberRegExp = new RegExp(r'^\d+$');

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
			pax.groupError = 'Ange förening.';
		} else {
			pax.groupError = null;
		}

		if (isBlank(pax.firstName)) {
			pax.firstNameError = 'Ange förnamn.';
		} else {
			pax.firstNameError = null;
		}

		if (isBlank(pax.lastName)) {
			pax.lastNameError = 'Ange efternamn.';
		} else {
			pax.lastNameError = null;
		}

		if (isBlank(pax.dob)) {
			pax.dobError = 'Ange födelsedatum.';
		} else if (!_isValidDate(pax.dob)) {
			pax.dobError = 'Ange ett giltigt datum.';
		} else {
			pax.dobError = null;
		}

		if (!isBlank(pax.nationality) && !_nationalityRegExp.hasMatch(pax.nationality)) {
			pax.nationalityError = 'Ange landskod (tomt för Sverige).';
		} else {
			pax.nationalityError = null;
		}

		if (!isBlank(pax.years) && !_numberRegExp.hasMatch(pax.years)) {
			pax.yearsError = 'Ange siffror.';
		} else {
			pax.yearsError = null;
		}

		return pax.isValid;
	}

	bool validateProduct(BookingProductView product) {
		if (!isBlank(product.quantity) && !_numberRegExp.hasMatch(product.quantity)) {
			product.quantityError = 'Ange siffror.';
		} else if (!isBlank(product.quantity) && product.quantity.length > 3) {
			product.quantity = '999';
		} else {
			product.quantityError = null;
		}

		return product.isValid;
	}

	// Mildly dubious conversion - interpret as 20xx unless that would be in the future, otherwise 19xx
	static bool _isLeapYear(int twoDigitYear) {
		final int thisYear = (new DateTime.now()).year;
		final int year = 2000 + twoDigitYear > thisYear ? 1900 + twoDigitYear : 2000 + twoDigitYear;
		return 0 == year % 4 && (0 != year % 100 || 0 == year % 400);
	}

	// Dart's DateFormat doesn't do very good validation of dates so we use this simple version
	bool _isValidDate(String dob) {
		if (!_dobRegExp.hasMatch(dob)) {
			return false;
		}

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
