import 'dart:async';

import 'package:angular2/core.dart';

import '../booking/availability_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise.dart';

@Component(
	selector: 'start-page',
	styleUrls: const ['content_styles.css', 'start_page.css'],
	templateUrl: 'start_page.html',
	directives: const <dynamic>[AvailabilityComponent]
)
class StartPage implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	bool cruiseIsUnlocked;

	StartPage(this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			final Cruise cruise = await _cruiseRepository.getActiveCruise(client);
			cruiseIsUnlocked = !cruise.isLocked;
		} catch (e) {
			print('Failed to load active cruise: ' + e.toString());
			// Safe to ignore as it just means we won't show the availability on the start page
		}
	}
}
