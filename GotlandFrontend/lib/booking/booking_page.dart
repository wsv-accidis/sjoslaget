import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';

import '../booking/pax_component.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['../content/content_styles.css', 'booking_page.css'],
	templateUrl: 'booking_page.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives, PaxComponent],
	providers: const <dynamic>[materialProviders]
)
class BookingPage implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final Router _router;

	@ViewChild('pax')
	PaxComponent pax;

	BookingPage(this._clientFactory, this._eventRepository, this._router);

	Future<Null> ngOnInit() async {
		/*if(!_clientFactory.hasCredentials){
			print('Booking page opened without credentials.');
			_router.navigate(<dynamic>['/Content/Start']);
			return;
		}*/

		// TODO Load the actual booking in case it already has stuff in it
		try {
			final client = _clientFactory.getClient();
		} catch (e) {

		}

		pax.initialEmptyPax = 5;
	}
}
