import 'package:angular/angular.dart';
import 'package:frontend_shared/util.dart' show ValidationSupport;
import 'package:quiver/strings.dart' as str show isBlank;

import '../model/booking_pax_view.dart';

@Injectable()
class BookingValidator {
	bool validatePax(BookingPaxView pax) {
		pax.clearErrors();

		if (pax.isEmpty) {
			return true;
		}

		if (str.isBlank(pax.firstName)) {
			pax.firstNameError = 'Ange förnamn.';
		}

		if (str.isBlank(pax.lastName)) {
			pax.lastNameError = 'Ange efternamn.';
		}

		if (str.isBlank(pax.gender)) {
			pax.genderError = 'Ange kön.';
		}

		if (str.isBlank(pax.dob)) {
			pax.dobError = 'Ange födelsedatum.';
		} else if (!ValidationSupport.isDateOfBirth(pax.dob)) {
			pax.dobError = 'Ange ett giltigt datum.';
		}

		if (null == pax.cabinClassMin) {
			pax.cabinClassMinError = 'Välj lägsta boende.';
		}

		if (null == pax.cabinClassPreferred) {
			pax.cabinClassPreferredError = 'Välj önskat boende.';
		}

		if (null == pax.cabinClassMax) {
			pax.cabinClassMaxError = 'Välj högsta boende.';
		}

		if (null != pax.cabinClassPreferred) {
			if(null != pax.cabinClassMin && pax.cabinClassPreferred.no < pax.cabinClassMin.no) {
				pax.cabinClassPreferredError = 'Önskat < lägsta.';
			} else if(null != pax.cabinClassMax && pax.cabinClassPreferred.no > pax.cabinClassMax.no) {
				pax.cabinClassPreferredError = 'Önskat > högsta.';
			}
		}

		if (null != pax.cabinClassMax && null != pax.cabinClassMin && pax.cabinClassMax.no < pax.cabinClassMin.no) {
			pax.cabinClassMaxError = pax.cabinClassMinError = 'Högsta < lägsta.';
		}

		return pax.isValid;
	}
}
