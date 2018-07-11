import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../booking/availability_component.dart';
import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../client/cruise_repository.dart';
import '../model/booking_dashboard_item.dart';
import '../model/cruise.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_dashboard_page.css'],
	directives: const<dynamic>[CORE_DIRECTIVES, ROUTER_DIRECTIVES, materialDirectives, AvailabilityComponent, SpinnerWidget],
	providers: const<dynamic>[materialProviders]
)
class AdminDashboardPage implements OnInit, OnDestroy {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;

	bool _isLockingUnlocking = false;
	Timer _timer;

	@ViewChild('availabilityComponent')
	AvailabilityComponent availabilityComponent;

	Cruise cruise;
	List<BookingDashboardItem> recentlyUpdatedBookings;

	bool get cruiseIsLocked => null != cruise && cruise.isLocked;

	bool get isLoadingCruise => null == cruise || _isLockingUnlocking;

	bool get isLoadingBookings => null == recentlyUpdatedBookings;

	AdminDashboardPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._router);

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	void logOut() {
		_clientFactory.clear();
		window.location.href = '/';
	}

	Future<Null> ngOnInit() async {
		if (!_clientFactory.isAdmin) {
			_router.navigate(<dynamic>['/Login']);
			return;
		}

		await _refreshRecentlyUpdated();
		_tick(null);
		_timer = new Timer.periodic(new Duration(milliseconds: 250), _tick);
	}

	void ngOnDestroy() {
		if (null != _timer)
			_timer.cancel();
	}

	Future<Null> lockUnlockCruise() async {
		if (null == cruise || _isLockingUnlocking)
			return;

		_isLockingUnlocking = true;
		try {
			final client = _clientFactory.getClient();
			final bool isLocked = await _cruiseRepository.lockUnlockCruise(client);
			cruise.isLocked = isLocked;
		} catch (e) {
			print('Failed to lock/unlock cruise: ' + e.toString());
		} finally {
			_isLockingUnlocking = false;
		}
	}

	void refresh() {
		_refreshRecentlyUpdated();
		_refreshAvailability();
	}

	Future<Null> _refreshAvailability() async {
		await availabilityComponent.refresh();
	}

	Future<Null> _refreshRecentlyUpdated() async {
		try {
			final client = _clientFactory.getClient();
			cruise = await _cruiseRepository.getActiveCruise(client);
			recentlyUpdatedBookings = await _bookingRepository.getRecentlyUpdated(client);
		} on ExpirationException catch (e) {
			print(e.toString());
			_clientFactory.clear();
			_router.navigate(<dynamic>['/Login']);
		} catch (e) {
			print('Failed to load recently updated bookings: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	void _tick(Timer ignored) {
		if (null == recentlyUpdatedBookings)
			return;

		final now = new DateTime.now();
		for (BookingDashboardItem item in recentlyUpdatedBookings)
			item.update(now);
	}
}
