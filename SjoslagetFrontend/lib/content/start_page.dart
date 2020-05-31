import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../booking/availability_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise.dart';
import 'content_routes.dart';

@Component(
    selector: 'start-page',
    styleUrls: ['content_styles.css', 'start_page.css'],
    templateUrl: 'start_page.html',
    directives: <dynamic>[coreDirectives, routerDirectives, AvailabilityComponent],
    exports: [ContentRoutes])
class StartPage implements OnInit {
  final ClientFactory _clientFactory;
  final CruiseRepository _cruiseRepository;

  bool cruiseIsUnlocked;

  StartPage(this._clientFactory, this._cruiseRepository);

  @override
  Future<Null> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      final Cruise cruise = await _cruiseRepository.getActiveCruise(client);
      cruiseIsUnlocked = !cruise.isLocked;
    } catch (e) {
      print('Failed to load active cruise: ${e.toString()}');
      // Safe to ignore as it just means we won't show the availability on the start page
    }
  }
}
