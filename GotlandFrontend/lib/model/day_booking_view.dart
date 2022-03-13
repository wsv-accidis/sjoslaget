import 'package:angular_components/angular_components.dart' show SelectionModel, SingleSelectionModel;
import 'package:quiver/strings.dart' as str show isNotEmpty;

import 'day_booking_source.dart';
import 'day_booking_type.dart';
import 'solo_booking_view.dart';

class DayBookingView extends SoloBookingView {
  String reference;
  String typeError;
  SingleSelectionModel<DayBookingType> typeSelection;
  bool paymentConfirmed;

  bool get hasTypeError => str.isNotEmpty(typeError);

  @override
  bool get isValid => super.isValid && !hasTypeError;

  DayBookingType get type => _selectedOrNull(typeSelection);

  DayBookingView.fromDayBookingSource(DayBookingSource source, List<DayBookingType> types) {
    reference = source.reference;
    firstName = source.firstName;
    lastName = source.lastName;
    phoneNo = source.phoneNo;
    email = source.email;
    dob = source.dob;
    foodSelection = SelectionModel<String>.single(selected: source.food);
    genderSelection = SelectionModel<String>.single(selected: source.gender);
    typeSelection = SelectionModel<DayBookingType>.single(selected: types.firstWhere((t) => t.id == source.typeId));
    paymentConfirmed = source.paymentConfirmed;
  }

  @override
  void clearErrors() {
    super.clearErrors();
    typeError = null;
  }

  DayBookingSource toDayBookingSource() =>
      DayBookingSource(reference, firstName, lastName, phoneNo, email, dob, food, gender, type.id, paymentConfirmed);

  T _selectedOrNull<T>(SelectionModel<T> selection) => selection.isNotEmpty ? selection.selectedValues.first : null;
}
