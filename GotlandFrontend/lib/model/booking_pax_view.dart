import 'package:angular_components/angular_components.dart' show SelectionModel;
import 'package:quiver/strings.dart' as str show isBlank, isNotEmpty;

import 'cabin_class.dart';
import 'trip.dart';

class BookingPaxView {
	String firstName;
	String firstNameError;
	String lastName;
	String lastNameError;
	SelectionModel<String> genderSelection;
	String dob;
	String dobError;
	String nationality;
	String nationalityError;
	SelectionModel<Trip> outboundTripSelection;
	SelectionModel<Trip> inboundTripSelection;
	bool isStudent;
	SelectionModel<CabinClass> cabinClassMinSelection;
	SelectionModel<CabinClass> cabinClassPreferredSelection;
	SelectionModel<CabinClass> cabinClassMaxSelection;
	String cabinClassError;
	String specialFood;

	CabinClass get cabinClassMax => _selectedOrNull(cabinClassMaxSelection);

	CabinClass get cabinClassMin => _selectedOrNull(cabinClassMinSelection);

	CabinClass get cabinClassPreferred => _selectedOrNull(cabinClassPreferredSelection);

	String get gender => _selectedOrNull(genderSelection);

	bool get hasFirstNameError => str.isNotEmpty(firstNameError);

	bool get hasLastNameError => str.isNotEmpty(lastNameError);

	bool get hasDobError => str.isNotEmpty(dobError);

	bool get hasNationalityError => str.isNotEmpty(nationalityError);

	bool get hasCabinClassError => str.isNotEmpty(cabinClassError);

	Trip get inboundTrip => _selectedOrNull(inboundTripSelection);

	bool get isEmpty => str.isBlank(firstName) && str.isBlank(lastName) && str.isBlank(dob);

	bool get isValid => !hasFirstNameError && !hasLastNameError && !hasDobError && !hasNationalityError && !hasCabinClassError;

	Trip get outboundTrip => _selectedOrNull(outboundTripSelection);

	BookingPaxView.createEmpty() {
		genderSelection = new SelectionModel<String>.withList();
		outboundTripSelection = new SelectionModel<Trip>.withList();
		inboundTripSelection = new SelectionModel<Trip>.withList();
		cabinClassMinSelection = new SelectionModel<CabinClass>.withList();
		cabinClassPreferredSelection = new SelectionModel<CabinClass>.withList();
		cabinClassMaxSelection = new SelectionModel<CabinClass>.withList();
	}

	void clearErrors() {
		firstNameError = null;
		lastNameError = null;
		dobError = null;
		nationalityError = null;
		cabinClassError = null;
	}

	T _selectedOrNull<T>(SelectionModel<T> selection) {
		return selection.isNotEmpty ? selection.selectedValues.first : null;
	}
}
