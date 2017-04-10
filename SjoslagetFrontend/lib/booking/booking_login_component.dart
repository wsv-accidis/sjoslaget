import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../widgets/modal_dialog.dart';

@Component(
	selector: 'booking-login',
	templateUrl: 'booking_login_component.html',
	directives: const [ROUTER_DIRECTIVES, materialDirectives, ModalDialog],
	providers: const [materialProviders]
)
class BookingLoginComponent {
	final ClientFactory _clientFactory;
	final Router _router;

	@ViewChild('loginFailedDialog')
	ModalDialog loginFailedDialog;

	String bookingRef;
	String pinCode;

	bool get isLoggedIn => _clientFactory.hasCredentials;

	String get loggedInUser => _clientFactory.authenticatedUser;

	BookingLoginComponent(this._clientFactory, this._router);

	Future<Null> logIn() async {
		try {
			await _clientFactory.authenticate(bookingRef, pinCode);
		} catch (e) {
			_clientFactory.clear();
			loginFailedDialog.open();
		}

		if (isLoggedIn)
			_router.navigate(['/MyBooking/EditCabins']);
	}

	void logOut() {
		_clientFactory.clear();
	}
}
