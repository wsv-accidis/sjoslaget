import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/queue_repository.dart';
import '../model/booking_details.dart';
import '../model/candidate_response.dart';
import '../model/event.dart';
import '../util/countdown_state.dart';

@Component(
	selector: 'start-page',
	styleUrls: const ['content_styles.css', 'start_page.css'],
	templateUrl: 'start_page.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives],
	providers: const <dynamic>[materialProviders]
)
class StartPage implements OnInit {
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final QueueRepository _queueRepository;
	final Router _router;

	Event _evnt;

	String firstName;
	String lastName;
	String phoneNo;
	String email;
	bool acceptToc = false;

	String get eventName => _evnt.name;

	String get eventOpening => null != _evnt.opening ? DateTimeFormatter.format(_evnt.opening)
		: 'någon gång i en avlägsen framtid';

	bool get isLoaded => null != _evnt;

	StartPage(this._clientFactory, this._eventRepository, this._queueRepository, this._router);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			_evnt = await _eventRepository.getActiveEvent(client);
		} catch (e) {
			print('Failed to load active event: ' + e.toString());
		}
	}

	Future<Null> submitDetails() async {
		final candidate = new BookingDetails(firstName, lastName, phoneNo, email);
		CandidateResponse response;

		try {
			_clientFactory.clear();
			final client = _clientFactory.getClient();
			response = await _queueRepository.createCandidate(client, candidate);
		} catch (e) {
			print('Failed to create booking candidate: ' + e.toString());
			return; // TODO Error message to user
		}

		final state = new CountdownState();
		state.update(response);

		_router.navigate(<dynamic>['/Content/Countdown']);
	}
}
