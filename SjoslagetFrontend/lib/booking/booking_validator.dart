import 'package:angular/angular.dart';
import 'package:frontend_shared/util.dart' show ValidationSupport;
import 'package:quiver/strings.dart' show isBlank;

import '../model/booking_cabin_view.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_product_view.dart';

@Injectable()
class BookingValidator {
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
		} else if (!ValidationSupport.isDateOfBirth(pax.dob)) {
			pax.dobError = 'Ange ett giltigt datum.';
		} else {
			pax.dobError = null;
		}

		if (!isBlank(pax.nationality) && !ValidationSupport.isTwoLetterNationality(pax.nationality)) {
			pax.nationalityError = 'Ange landskod (tomt för Sverige).';
		} else {
			pax.nationalityError = null;
		}

		if (!isBlank(pax.years) && !ValidationSupport.isSimpleInteger(pax.years)) {
			pax.yearsError = 'Ange siffror.';
		} else {
			pax.yearsError = null;
		}

		return pax.isValid;
	}

	bool validateProduct(BookingProductView product) {
		if (!isBlank(product.quantity) && !ValidationSupport.isSimpleInteger(product.quantity)) {
			product.quantityError = 'Ange siffror.';
		} else if (!isBlank(product.quantity) && product.quantity.length > 3) {
			product.quantity = '999';
		} else {
			product.quantityError = null;
		}

		return product.isValid;
	}
}
