import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart' show ValidationSupport;
import 'package:quiver/strings.dart' as str;

import '../client/client_factory.dart';
import '../client/external_booking_repository.dart';
import '../model/external_booking_source.dart';
import '../model/external_booking_type.dart';
import '../widgets/components.dart';

@Component(
	selector: 'external-booking-component',
	styleUrls: ['../content/content_styles.css', 'external_booking_component.css'],
	templateUrl: 'external_booking_component.html',
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives],
	providers: <dynamic>[materialProviders]
)
class ExternalBookingComponent implements OnInit {
	final ClientFactory _clientFactory;
	final ExternalBookingRepository _externalBookingRepository;
	final _onSubmit = StreamController<ExternalBookingSource>.broadcast();

	@Output()
	Stream get onSubmit => _onSubmit.stream;

	@ViewChild('bookingForm')
	NgForm bookingForm;

	String firstName;
	String lastName;
	String phoneNo;
	String dob;
	String specialRequest;
	SingleSelectionModel<ExternalBookingType> typeSelection = SelectionModel<ExternalBookingType>.single();
	SelectionOptions<ExternalBookingType> typeOptions;
	bool paymentReceived = false;
	bool acceptRules = false;
	bool acceptToc = false;
	String errorMessage;

	bool get canSubmit => acceptRules && acceptToc && null != type;

	bool get hasError => str.isNotEmpty(errorMessage);

	ExternalBookingType get type => typeSelection.selectedValue;

	ExternalBookingComponent(this._clientFactory, this._externalBookingRepository);

	@override
	Future<void> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			final types = await _externalBookingRepository.getTypes(client);
			typeOptions = SelectionOptions.fromList(types);
		} catch (e) {
			// Ignore this here - we will be stuck in the loading state until the user refreshes
			print('Failed to get data due to an exception: ${e.toString()}');
			return;
		}
	}

	int typeToPrice(ExternalBookingType type) => null != type ? type.price.toInt() : 0;

	String typeToString(ExternalBookingType type) => null != type ? '${type.title} (${typeToPrice(type)} kr)' : 'Välj biljett';

	void submit() {
		_validate();

		if (!hasError) {
			final booking = ExternalBookingSource(
				firstName,
				lastName,
				phoneNo,
				dob,
				specialRequest,
				type.id,
				paymentReceived
			);

			_onSubmit.add(booking);
			_clear();
		}
	}

	void _clear() {
		firstName = lastName = phoneNo = dob = specialRequest = '';
		acceptRules = acceptToc = paymentReceived = false;
		errorMessage = '';
		bookingForm.reset();
	}

	void _validate() {
		errorMessage = '';

		if (str.isEmpty(firstName) || str.isEmpty(lastName) || str.isEmpty(phoneNo)) {
			errorMessage = 'Obligatorisk information saknas. Kontrollera formuläret och försök igen.';
			return;
		}

		if (null == typeSelection.selectedValue) {
			errorMessage = 'Typ av biljett är inte vald. Kontrollera formuläret och försök igen.';
			return;
		}

		if (str.isEmpty(dob) || !ValidationSupport.isDateOfBirth(dob)) {
			errorMessage = 'Angivet födelsedatum är inte giltigt.';
			return;
		}

		if (!acceptRules || !acceptToc) {
			errorMessage = 'En eller flera bekräftelser saknas.';
			return;
		}
	}
}
