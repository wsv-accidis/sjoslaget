import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import '../booking/booking_component.dart';
import '../booking/booking_login_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_details.dart';
import '../model/cruise.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: const <dynamic>[CORE_DIRECTIVES, ROUTER_DIRECTIVES, formDirectives, materialDirectives, BookingLoginComponent, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class BookingPage implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;
	Cruise cruise;
	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String lunch;
	bool acceptToc;

	bool get isLoadingCruise => null == cruise;

	bool get isCruiseLocked => null == cruise || cruise.isLocked;

	BookingPage(this._clientFactory, this._cruiseRepository, this._router);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			cruise = await _cruiseRepository.getActiveCruise(client);
		} catch (e) {
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
			print('Failed to get cruise due to an exception: ' + e.toString());
		}
	}

	void submitDetails() {
		final bookingDetails = new BookingDetails(firstName, lastName, phoneNo, email, lunch, null);
		window.sessionStorage[BookingComponent.BOOKING] = bookingDetails.toJson();
		_router.navigate(<dynamic>['/MyBooking/EditCabins']);
	}
}
