import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart' show DateTimeFormatter;
import 'package:oauth2/oauth2.dart' show ExpirationException;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/queue_admin_repository.dart';
import '../model/event.dart';
import '../model/queue_dashboard_item.dart';
import '../util/countdown_state.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';
import 'availability_component.dart';

@Component(
    selector: 'admin-dashboard-page',
    templateUrl: 'admin_dashboard_page.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_dashboard_page.css'],
    directives: <dynamic>[coreDirectives, routerDirectives, gotlandMaterialDirectives, AvailabilityComponent, SpinnerWidget],
    exports: <dynamic>[AdminRoutes])
class AdminDashboardPage implements OnInit, OnDestroy {
  static const int COUNTDOWN_THRESHOLD_MINS = 30;
  static const int REFRESH_INTERVAL_LONG_MS = 60000;
  static const int REFRESH_INTERVAL_MEDIUM_MS = 10000;
  static const int REFRESH_INTERVAL_SHORT_MS = 1000;

  final ClientFactory _clientFactory;
  final BookingRepository _bookingRepository;
  final EventRepository _eventRepository;
  final QueueAdminRepository _queueAdminRepository;
  final Router _router;
  final TempCredentialsStore _tempCredentialsStore;

  final _countdown = CountdownState.empty();
  DateTime _eventOpening;
  bool _isLockingUnlocking = false;

  @ViewChild('availabilityComponent')
  AvailabilityComponent availabilityComponent;

  String countdownFormatted;
  Event event;
  bool isDestroyed = false;
  List<QueueDashboardItem> queueItems;

  String get eventOpening => DateTimeFormatter.format(_eventOpening);

  bool get hasCountdown => !_countdown.isElapsed;

  bool get hasOpening => null != _eventOpening;

  bool get isLoadingEvent => null == event;

  bool get isLoadingQueue => null == queueItems;

  AdminDashboardPage(this._bookingRepository, this._clientFactory, this._eventRepository, this._queueAdminRepository, this._router, this._tempCredentialsStore);

  void logOut() {
    _clientFactory.clear();
    window.location.href = '/';
  }

  @override
  Future<void> ngOnInit() async {
    if (!_clientFactory.isAdmin) {
      await _router.navigateByUrl(AdminRoutes.login.toUrl());
      return;
    }

    await _refreshEvent();
    await _refreshCountdown();
    await _refreshQueue();
    await availabilityComponent.refresh();

    Timer(Duration(milliseconds: _getRefreshInterval()), _refreshPeriodically);
  }

  @override
  void ngOnDestroy() {
    isDestroyed = true;
  }

  Future<void> createEmptyBooking() async {
    try {
      final client = _clientFactory.getClient();
      final result = await _bookingRepository.createEmpty(client);
      _tempCredentialsStore.save(result);
      await _router.navigateByUrl(AdminRoutes.bookingUrl(result.reference));
    } catch (e) {
      print('Failed to create empty booking: ${e.toString()}');
    }
  }

  Future<void> lockUnlockEvent() async {
    if (_isLockingUnlocking) return;

    _isLockingUnlocking = true;
    try {
      final client = _clientFactory.getClient();
      final bool isLocked = await _eventRepository.lockUnlockEvent(client);
      event.isLocked = isLocked;
    } catch (e) {
      print('Failed to lock/unlock event: ${e.toString()}');
    } finally {
      _isLockingUnlocking = false;
    }
  }

  int _getRefreshInterval() {
    if (null != event) {
      if (event.isLocked || !hasCountdown) {
        // Nothing will happen, no point in refreshing often
        return REFRESH_INTERVAL_LONG_MS;
      }

      if (_countdown.inMinutes < COUNTDOWN_THRESHOLD_MINS) {
        // We are in the final stages of countdown, update frequently
        return REFRESH_INTERVAL_SHORT_MS;
      }
    }

    // Any other option
    return REFRESH_INTERVAL_MEDIUM_MS;
  }

  Future<void> _refreshCountdown() async {
    try {
      final client = _clientFactory.getClient();
      final response = await _queueAdminRepository.getCountdown(client);
      _eventOpening = response.opening;
      _countdown.updateCountdown(response.countdown);
      countdownFormatted = _countdown.toString();
    } catch (e) {
      print('Failed to refresh countdown: ${e.toString()}');
    }
  }

  Future<void> _refreshEvent() async {
    try {
      final client = _clientFactory.getClient();
      event = await _eventRepository.getActiveEvent(client);
    } catch (e) {
      print('Failed to load event: ${e.toString()}');
    }
  }

  Future<void> _refreshQueue() async {
    try {
      final client = _clientFactory.getClient();
      queueItems = await _queueAdminRepository.getQueue(client);

      final now = DateTime.now();
      for (QueueDashboardItem item in queueItems) item.update(now);

      await availabilityComponent.refresh();
    } on ExpirationException catch (e) {
      print(e.toString());
      _clientFactory.clear();
      await _router.navigateByUrl(AdminRoutes.login.toUrl());
    } catch (e) {
      print('Failed to load queue dashboard: ${e.toString()}');
    }
  }

  void _refreshPeriodically() {
    if (isDestroyed) return;
    if (hasCountdown) countdownFormatted = _countdown.toString();

    _refreshQueue().whenComplete(() => Timer(Duration(milliseconds: _getRefreshInterval()), _refreshPeriodically));
  }
}
