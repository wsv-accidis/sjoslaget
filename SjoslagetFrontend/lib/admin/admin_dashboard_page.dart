import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../booking/availability_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_dashboard_item.dart';
import '../model/cruise.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_dashboard_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, sjoslagetMaterialDirectives, AvailabilityComponent, SpinnerWidget],
	exports: <dynamic>[AdminRoutes]
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

	AdminDashboardPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._router);

	bool get cruiseIsLocked => null != cruise && cruise.isLocked;

	bool get isLoadingCruise => null == cruise || _isLockingUnlocking;

	bool get isLoadingBookings => null == recentlyUpdatedBookings;

	String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

	void logOut() {
		_clientFactory.clear();
		window.location.href = '/';
	}

	@override
	Future<Null> ngOnInit() async {
		if (!_clientFactory.isAdmin) {
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
			return;
		}

		await _refreshRecentlyUpdated();
		_tick(null);
		_timer = Timer.periodic(Duration(milliseconds: 250), _tick);
	}

	@override
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
			print('Failed to lock/unlock cruise: ${e.toString()}');
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
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
		} catch (e) {
			print('Failed to load recently updated bookings: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	void _tick(Timer ignored) {
		if (null == recentlyUpdatedBookings)
			return;

		final now = DateTime.now();
		for (BookingDashboardItem item in recentlyUpdatedBookings)
			item.update(now);
	}
}
