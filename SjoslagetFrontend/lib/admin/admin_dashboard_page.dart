import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../model/booking_dashboard_item.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_dashboard_page.css'],
	directives: const [ROUTER_DIRECTIVES, materialDirectives, SpinnerWidget],
	providers: const [materialProviders]
)
class AdminDashboardPage implements OnInit, OnDestroy {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final Router _router;
	Timer _timer;

	List<BookingDashboardItem> recentlyUpdatedBookings;

	AdminDashboardPage(this._bookingRepository, this._clientFactory, this._router);

	void logOut() {
		_clientFactory.clear();
		_router.navigate(['/Content/Start']);
	}

	Future<Null> ngOnInit() async {
		if (!_clientFactory.isAdmin) {
			_router.navigate(['/Admin/Login']);
			return;
		}

		try {
			final client = await _clientFactory.getClient();
			recentlyUpdatedBookings = await _bookingRepository.getRecentlyUpdated(client);
		} catch (e) {
			print('Failed to load recently updated bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}

		tick(null);
		_timer = new Timer.periodic(new Duration(milliseconds: 250), tick);
	}

	void ngOnDestroy() {
		if (null != _timer)
			_timer.cancel();
	}

	void tick(Timer ignored) {
		if (null == recentlyUpdatedBookings)
			return;

		final now = new DateTime.now();
		for (BookingDashboardItem item in recentlyUpdatedBookings)
			item.update(now);
	}
}
