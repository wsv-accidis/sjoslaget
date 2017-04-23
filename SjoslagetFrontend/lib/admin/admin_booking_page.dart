import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-booking-page',
	templateUrl: 'admin_booking_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_dashboard_page.css'],
	directives: const<dynamic>[materialDirectives, SpinnerWidget],
	providers: const<dynamic>[materialProviders]
)
class AdminBookingPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	AdminBookingPage(this._bookingRepository, this._clientFactory);

	Future<Null> ngOnInit() async {
		try {
			final client = await _clientFactory.getClient();
		} catch (e) {
			print('Failed to load booking: ' + e);
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}
}
