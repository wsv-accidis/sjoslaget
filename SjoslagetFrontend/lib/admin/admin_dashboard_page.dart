import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../model/booking_dashboard_item.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: const ['../content/content_styles.css'],
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class AdminDashboardPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;

	List<BookingDashboardItem> recentlyUpdatedBookings;

	AdminDashboardPage(this._bookingRepository, this._clientFactory);

	Future<Null> ngOnInit() async {
		try {
			final client = await _clientFactory.getClient();
			recentlyUpdatedBookings = await _bookingRepository.getRecentlyUpdated(client);
		} catch (e) {
			print('Failed to load recently updated bookings: ' + e);
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}
}
