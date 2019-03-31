import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart' show ValidationSupport;
import 'package:quiver/strings.dart' as str;

import '../model/external_booking.dart';
import '../widgets/components.dart';

@Component(
	selector: 'external-booking-component',
	styleUrls: ['../content/content_styles.css', 'external_booking_component.css'],
	templateUrl: 'external_booking_component.html',
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives],
	providers: <dynamic>[materialProviders]
)
class ExternalBookingComponent {
	static const String FRIDAY = 'fri';
	static const String SATURDAY = 'sat';
	static const String WHOLE_EVENT = 'all';

	final _onSubmit = StreamController<ExternalBooking>.broadcast();

	@Output()
	Stream get onSubmit => _onSubmit.stream;

	@ViewChild('bookingForm')
	NgForm bookingForm;

	String firstName;
	String lastName;
	String phoneNo;
	String dob;
	String specialRequest;
	SingleSelectionModel<String> daySelection = SelectionModel<String>.single(selected: WHOLE_EVENT);
	SelectionOptions<String> dayOptions = SelectionOptions.fromList(<String>[WHOLE_EVENT, FRIDAY, SATURDAY]);
	bool isRindiMember = false;
	bool acceptRules = false;
	bool acceptToc = false;
	bool confirmPayment = false;
	String errorMessage;

	bool get canSubmit => acceptRules && acceptToc && confirmPayment;

	String get days => daySelection.selectedValue;

	bool get hasError => str.isNotEmpty(errorMessage);

	int dayToPrice(String day) {
		if (day == FRIDAY || day == SATURDAY) {
			return 400;
		} else if (day == WHOLE_EVENT) {
			return 750;
		} else {
			return 0;
		}
	}

	String dayToString(String day) {
		if (day == FRIDAY) {
			return 'Biljett för fredag (${dayToPrice(day)} kr)';
		} else if (day == SATURDAY) {
			return 'Biljett för lördag (${dayToPrice(day)} kr)';
		} else if (day == WHOLE_EVENT) {
			return 'Biljett för fredag och lördag (${dayToPrice(day)} kr)';
		} else {
			return '';
		}
	}

	void submit() {
		_validate();

		if (!hasError) {
			final booking = ExternalBooking(
				firstName,
				lastName,
				phoneNo,
				dob,
				specialRequest,
				isRindiMember,
				_isFriday,
				_isSaturday
			);

			_onSubmit.add(booking);
			_clear();
		}
	}

	bool get _isFriday => days == FRIDAY || days == WHOLE_EVENT;

	bool get _isSaturday => days == SATURDAY || days == WHOLE_EVENT;

	void _clear() {
		firstName = lastName = phoneNo = dob = specialRequest = '';
		isRindiMember = acceptRules = acceptToc = confirmPayment = false;
		errorMessage = '';
		bookingForm.reset();
	}

	void _validate() {
		errorMessage = '';

		if (str.isEmpty(firstName) || str.isEmpty(lastName) || str.isEmpty(phoneNo)) {
			errorMessage = 'Obligatorisk information saknas. Kontrollera formuläret och försök igen.';
			return;
		}

		if (!_isFriday && !_isSaturday) {
			errorMessage = 'Typ av biljett är inte vald. Kontrollera formuläret och försök igen.';
			return;
		}

		if (str.isEmpty(dob) || !ValidationSupport.isDateOfBirth(dob)) {
			errorMessage = 'Angivet födelsedatum är inte giltigt.';
			return;
		}

		if (!acceptRules || !acceptToc || !confirmPayment) {
			errorMessage = 'En eller flera bekräftelser saknas.';
			return;
		}
	}
}
