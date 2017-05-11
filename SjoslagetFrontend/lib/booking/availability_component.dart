import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'availability-component',
	templateUrl: 'availability_component.html',
	styleUrls: const ['../content/content_styles.css', 'availability_component.css'],
	directives: const<dynamic>[materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class AvailabilityComponent implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	Map<String, int> availability;
	List<CruiseCabin> cabins;

	bool get isLoading => null == cabins;

	AvailabilityComponent(this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			availability = await _cruiseRepository.getAvailability(client);
			cabins = await _cruiseRepository.getActiveCruiseCabins(client);
		} catch (e) {
			print('Failed to load cabins and availability: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	int getAvailability(String id) {
		if (null == availability || !availability.containsKey(id))
			return 0;
		return availability[id];
	}
}
