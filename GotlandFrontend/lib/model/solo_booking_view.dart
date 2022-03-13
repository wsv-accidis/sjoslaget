import 'package:angular_components/angular_components.dart' show SelectionModel, SingleSelectionModel;
import 'package:quiver/strings.dart' as str show isBlank, isNotEmpty;

class SoloBookingView {
  String firstName;
  String firstNameError;
  String lastName;
  String lastNameError;
  String phoneNo;
  String phoneNoError;
  String email;
  String emailError;
  String dob;
  String dobError;
  SingleSelectionModel<String> foodSelection = SelectionModel<String>.single();
  String foodError;
  SingleSelectionModel<String> genderSelection = SelectionModel<String>.single();
  String genderError;

  String get food => _selectedOrNull(foodSelection);

  String get gender => _selectedOrNull(genderSelection);

  bool get hasFirstNameError => str.isNotEmpty(firstNameError);

  bool get hasLastNameError => str.isNotEmpty(lastNameError);

  bool get hasPhoneNoError => str.isNotEmpty(phoneNoError);

  bool get hasEmailError => str.isNotEmpty(emailError);

  bool get hasDobError => str.isNotEmpty(dobError);

  bool get hasFoodError => str.isNotEmpty(foodError);

  bool get hasGenderError => str.isNotEmpty(genderError);

  bool get isEmpty => str.isBlank(firstName) && str.isBlank(lastName);

  bool get isValid => !hasFirstNameError && !hasLastNameError && !hasPhoneNoError && !hasEmailError && !hasDobError && !hasFoodError && !hasGenderError;

  void clear() {
    firstName = '';
    lastName = '';
    phoneNo = '';
    email = '';
    dob = '';
    foodSelection.clear();
    genderSelection.clear();
    clearErrors();
  }

  void clearErrors() {
    firstNameError = null;
    lastNameError = null;
    phoneNoError = null;
    emailError = null;
    dobError = null;
    foodError = null;
    genderError = null;
  }

  T _selectedOrNull<T>(SelectionModel<T> selection) => selection.isNotEmpty ? selection.selectedValues.first : null;
}
