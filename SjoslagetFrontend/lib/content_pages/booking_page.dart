import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class BookingPage {
	final ClientFactory _clientFactory;

	String bookingRef;
	String pinCode;
	
	bool get isLoggedIn => _clientFactory.hasCredentials;

	BookingPage(this._clientFactory);

	void authenticate() {
		_clientFactory.authenticate(bookingRef, pinCode);
	}
}
