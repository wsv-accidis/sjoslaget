import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/claimed_capacity.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'availability-component',
	templateUrl: 'availability_component.html',
	styleUrls: ['../content/content_styles.css', 'availability_component.css'],
	directives: <dynamic>[coreDirectives, MaterialProgressComponent, SpinnerWidget]
)
class AvailabilityComponent implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	List<ClaimedCapacity> claimed;

	AvailabilityComponent(this._clientFactory, this._eventRepository);

	bool get isLoading => null == claimed;

	@override
	Future<void> ngOnInit() async {
		await refresh();
	}

	Future<void> refresh() async {
		try {
			final client = _clientFactory.getClient();
			claimed = await _eventRepository.getClaimedCapacity(client);
		} catch (e) {
			print('Failed to load claimed capacity: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}
}
