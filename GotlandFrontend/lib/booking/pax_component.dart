import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/cabin_class.dart';
import '../model/trip.dart';

@Component(
	selector: 'pax-component',
	styleUrls: const ['../content/content_styles.css', 'pax_component.css'],
	templateUrl: 'pax_component.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives],
	providers: const <dynamic>[materialProviders]
)
class PaxComponent implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	List<CabinClass> cabinClasses;
	List<Trip> inboundTrips;
	List<Trip> outboundTrips;

	bool get isLoaded => null != cabinClasses && null != inboundTrips && null != outboundTrips;

	PaxComponent(this._clientFactory, this._eventRepository);

	Future<Null> ngOnInit() async {
		//try {
			final client = _clientFactory.getClient();
			cabinClasses = await _eventRepository.getCabinClasses(client);
			inboundTrips = await _eventRepository.getInboundTrips(client);
			outboundTrips = await _eventRepository.getOutboundTrips(client);
		//} catch (e) {
			//print('Failed to get data due to an exception: ' + e.toString());
			// Ignore this here - we will be stuck in the loading state until the user refreshes
		//}
	}
}
