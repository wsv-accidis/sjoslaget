import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../booking/availability_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise.dart';
import '../util/countdown.dart';
import 'content_routes.dart';

@Component(
    selector: 'start-page',
    styleUrls: ['content_styles.css', 'start_page.css'],
    templateUrl: 'start_page.html',
    directives: <dynamic>[coreDirectives, routerDirectives, AvailabilityComponent],
    exports: [ContentRoutes])
class StartPage implements OnInit, OnDestroy {
  static const int COUNTDOWN_REFRESH_INTERVAL = 100;

  // Not used for 2023
  final Countdown _countdown = Countdown(DateTime(2022, 8, 31, 12));

  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;

  bool _isDestroyed = false;

  String countdownFormatted = '';

  bool cruiseIsUnlocked = false;

  StartPage(this._clientFactory, this._cruiseRepository);

  @override
  Future<void> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      final Cruise cruise = await _cruiseRepository.getActiveCruise(client);
      cruiseIsUnlocked = !cruise.isLocked;
    } catch (e) {
      print('Failed to load active cruise: ${e.toString()}');
      // Safe to ignore as it just means we won't show the availability on the start page
    }

    if (!cruiseIsUnlocked && !_countdown.isElapsed) {
      Timer(const Duration(milliseconds: COUNTDOWN_REFRESH_INTERVAL), _refreshCountdown);
    }
  }

  @override
  void ngOnDestroy() {
    _isDestroyed = true;
  }

  void _refreshCountdown() {
    if (_isDestroyed) return;
    if (_countdown.isElapsed) {
      countdownFormatted = '';
      return;
    }

    countdownFormatted = _countdown.toString();
    Timer(const Duration(milliseconds: COUNTDOWN_REFRESH_INTERVAL), _refreshCountdown);
  }
}
