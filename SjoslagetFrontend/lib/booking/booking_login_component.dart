import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';

import '../client/client_factory.dart';
import '../widgets/components.dart';
import 'booking_component.dart';
import 'booking_routes.dart';

@Component(
	selector: 'booking-login',
	templateUrl: 'booking_login_component.html',
	styleUrls: ['booking_login_component.css', '../content/content_styles.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, ModalDialog],
	exports: <dynamic>[BookingRoutes]
)
class BookingLoginComponent {
	final ClientFactory _clientFactory;
	final Router _router;

	@ViewChild('loginFailedDialog')
	ModalDialog loginFailedDialog;

	String bookingRef;
	String pinCode;

	BookingLoginComponent(this._clientFactory, this._router);

	bool get isLoggedIn => _clientFactory.hasCredentials;

	String get loggedInUser => _clientFactory.authenticatedUser;

	Future<void> logIn() async {
		try {
			await _clientFactory.authenticate(bookingRef, pinCode);
		} catch (e) {
			_clientFactory.clear();
			loginFailedDialog.open();
		}

		if (isLoggedIn) {
			// Ensure we do not have booking details in session storage before going into edit mode
			window.sessionStorage.remove(BookingComponent.BOOKING);
			await _router.navigateByUrl(BookingRoutes.editBooking.toUrl());
		}
	}

	void logOut() {
		_clientFactory.clear();
	}
}
