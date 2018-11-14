import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;
import 'package:quiver/strings.dart' as str show isEmpty;

import '../booking/booking_component.dart';
import '../booking/booking_login_component.dart';
import '../booking/booking_routes.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_details.dart';
import '../model/cruise.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'about_routes.dart';
import 'content_routes.dart';

@Component(
	selector: 'booking-page',
	styleUrls: ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, BookingLoginComponent, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: [AboutRoutes, ContentRoutes]
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
	bool acceptToc = false;

	BookingPage(this._clientFactory, this._cruiseRepository, this._router);

	bool get isLoadingCruise => null == cruise;

	bool get isCruiseLocked => null == cruise || cruise.isLocked;

	Future<Null> doInit() async {
		try {
			final client = _clientFactory.getClient();
			cruise = await _cruiseRepository.getActiveCruise(client);
		} on ExpirationException {
			rethrow;
		} catch (e) {
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
			print('Failed to get cruise due to an exception: ${e.toString()}');
		}
	}

	@override
	Future<Null> ngOnInit() async {
		try {
			await doInit();
		} on ExpirationException catch (e) {
			print(e.toString());
			_clientFactory.clear();
			await doInit();
		}
	}

	Future<Null> submitDetails() async {
		if (!acceptToc) {
			return;
		}
		if (str.isEmpty(lunch)) {
			// Vårkryssen doesn't use lunch so just set a dummy value
			lunch = '-';
		}

		final bookingDetails = BookingDetails(firstName, lastName, phoneNo, email, lunch, null);
		window.sessionStorage[BookingComponent.BOOKING] = bookingDetails.toJson();
		await _router.navigateByUrl(BookingRoutes.editBooking.toUrl());
	}
}
