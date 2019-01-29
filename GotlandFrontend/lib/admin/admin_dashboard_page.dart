import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart' show DateTimeFormatter;
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../client/client_factory.dart';
import '../client/queue_admin_repository.dart';
import '../model/queue_dashboard_item.dart';
import '../util/countdown_state.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-dashboard-page',
	templateUrl: 'admin_dashboard_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_dashboard_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, gotlandMaterialDirectives, SpinnerWidget],
	exports: <dynamic>[AdminRoutes]
)
class AdminDashboardPage implements OnInit, OnDestroy {
	static const int REFRESH_INTERVAL_MS = 1000;

	final ClientFactory _clientFactory;
	final QueueAdminRepository _queueAdminRepository;
	final Router _router;

	final _countdown = CountdownState.empty();
	DateTime _eventOpening;

	String countdownFormatted;
	bool isDestroyed = false;
	List<QueueDashboardItem> queueItems;

	String get eventOpening => DateTimeFormatter.format(_eventOpening);

	bool get hasCountdown => !_countdown.isElapsed;

	bool get hasOpening => null != _eventOpening;

	bool get isLoadingQueue => null == queueItems;

	AdminDashboardPage(this._clientFactory, this._queueAdminRepository, this._router);

	@override
	Future<void> ngOnInit() async {
		if (!_clientFactory.isAdmin) {
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
			return;
		}

		await _refreshCountdown();
		await _refreshQueue();
		Timer(Duration(milliseconds: REFRESH_INTERVAL_MS), _refreshPeriodically);
	}

	@override
	void ngOnDestroy() {
		isDestroyed = true;
	}

	Future<void> _refreshCountdown() async {
		try {
			final client = _clientFactory.getClient();
			final response = await _queueAdminRepository.getCountdown(client);
			_eventOpening = response.opening;
			_countdown.updateCountdown(response.countdown);
			countdownFormatted = _countdown.toString();
		} catch(e) {
			print('Failed to refresh countdown: ${e.toString()}');
		}
	}

	Future<void> _refreshQueue() async {
		try {
			final client = _clientFactory.getClient();
			queueItems = await _queueAdminRepository.getQueue(client);

			final now = DateTime.now();
			for (QueueDashboardItem item in queueItems)
				item.update(now);
		} on ExpirationException catch (e) {
			print(e.toString());
			_clientFactory.clear();
			await _router.navigateByUrl(AdminRoutes.login.toUrl());
		} catch (e) {
			print('Failed to load queue dashboard: ${e.toString()}');
		}
	}

	void _refreshPeriodically() {
		if (isDestroyed)
			return;
		if (hasCountdown)
			countdownFormatted = _countdown.toString();

		_refreshQueue().whenComplete(() => Timer(Duration(milliseconds: REFRESH_INTERVAL_MS), _refreshPeriodically));
	}
}
