import 'package:angular_components/angular_components.dart' show SelectionModel, SingleSelectionModel;
import 'package:quiver/strings.dart' as str show isBlank, isNotEmpty;

import 'booking_pax.dart';
import 'cabin_class.dart';

class BookingPaxView {
	String firstName;
	String firstNameError;
	String lastName;
	String lastNameError;
	SingleSelectionModel<String> genderSelection;
	String genderError;
	String dob;
	String dobError;
	SingleSelectionModel<String> foodSelection;
	String foodError;
	SingleSelectionModel<CabinClass> cabinClassMinSelection;
	String cabinClassMinError;
	SingleSelectionModel<CabinClass> cabinClassPreferredSelection;
	String cabinClassPreferredError;
	SingleSelectionModel<CabinClass> cabinClassMaxSelection;
	String cabinClassMaxError;

	CabinClass get cabinClassMax => _selectedOrNull(cabinClassMaxSelection);

	CabinClass get cabinClassMin => _selectedOrNull(cabinClassMinSelection);

	CabinClass get cabinClassPreferred => _selectedOrNull(cabinClassPreferredSelection);

	String get food => _selectedOrNull(foodSelection);

	String get gender => _selectedOrNull(genderSelection);

	bool get hasFirstNameError => str.isNotEmpty(firstNameError);

	bool get hasLastNameError => str.isNotEmpty(lastNameError);

	bool get hasGenderError => str.isNotEmpty(genderError);

	bool get hasDobError => str.isNotEmpty(dobError);

	bool get hasFoodError => str.isNotEmpty(foodError);

	bool get hasCabinClassError => str.isNotEmpty(cabinClassMinError) || str.isNotEmpty(cabinClassPreferredError) || str.isNotEmpty(cabinClassMaxError);

	bool get isEmpty => str.isBlank(firstName) && str.isBlank(lastName) && str.isBlank(dob);

	bool get isValid => !hasFirstNameError && !hasLastNameError && !hasGenderError && !hasDobError && !hasFoodError && !hasCabinClassError;

	int get priceMax => null != cabinClassMax ? cabinClassMax.pricePerPax.toInt() : 0;

	int get priceMin => null != cabinClassMin ? cabinClassMin.pricePerPax.toInt() : 0;

	int get pricePreferred => null != cabinClassPreferred ? cabinClassPreferred.pricePerPax.toInt() : 0;

	static List<BookingPaxView> listOfBookingPaxToList(List<BookingPax> list, List<CabinClass> cabinClasses) =>
		list.map((p) => BookingPaxView.fromBookingPax(p, cabinClasses)).toList();

	static List<BookingPax> listToListOfBookingPax(List<BookingPaxView> list) =>
		list.where((p) => !p.isEmpty).map((p) => p._toBookingPax()).toList(growable: false);

	BookingPaxView.createEmpty() {
		foodSelection = SelectionModel<String>.single();
		genderSelection = SelectionModel<String>.single();
		cabinClassMinSelection = SelectionModel<CabinClass>.single();
		cabinClassPreferredSelection = SelectionModel<CabinClass>.single();
		cabinClassMaxSelection = SelectionModel<CabinClass>.single();
	}

	BookingPaxView.fromBookingPax(BookingPax pax, List<CabinClass> cabinClasses) {
		firstName = pax.firstName;
		lastName = pax.lastName;
		foodSelection = SelectionModel<String>.single(selected: pax.food);
		genderSelection = SelectionModel<String>.single(selected: pax.gender);
		dob = pax.dob;
		cabinClassMinSelection = SelectionModel<CabinClass>.single(selected: _getCabinClass(pax.cabinClassMin, cabinClasses));
		cabinClassPreferredSelection = SelectionModel<CabinClass>.single(selected: _getCabinClass(pax.cabinClassPreferred, cabinClasses));
		cabinClassMaxSelection = SelectionModel<CabinClass>.single(selected: _getCabinClass(pax.cabinClassMax, cabinClasses));
	}

	void clearErrors() {
		firstNameError = null;
		lastNameError = null;
		genderError = null;
		dobError = null;
		foodError = null;
		cabinClassMinError = null;
		cabinClassPreferredError = null;
		cabinClassMaxError = null;
	}

	static CabinClass _getCabinClass(int no, List<CabinClass> cabinClasses) =>
		cabinClasses.firstWhere((c) => c.no == no);

	T _selectedOrNull<T>(SelectionModel<T> selection) => selection.isNotEmpty ? selection.selectedValues.first : null;

	BookingPax _toBookingPax() =>
		BookingPax(
			firstName,
			lastName,
			genderSelection.selectedValue,
			dob,
			foodSelection.selectedValue,
			cabinClassMinSelection.selectedValue.no,
			cabinClassPreferredSelection.selectedValue.no,
			cabinClassMaxSelection.selectedValue.no
		);
}
