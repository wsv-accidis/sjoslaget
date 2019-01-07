import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/iterables.dart';

import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/queue_repository.dart';
import '../model/booking_details.dart';
import '../model/candidate_response.dart';
import '../model/event.dart';
import '../util/countdown_state.dart';
import 'content_routes.dart';

@Component(
	selector: 'start-page',
	styleUrls: ['content_styles.css', 'start_page.css'],
	templateUrl: 'start_page.html',
	directives: <dynamic>[coreDirectives, formDirectives, materialDirectives],
	providers: <dynamic>[materialProviders]
)
class StartPage implements OnInit {
	static const int TEAM_SIZE_MIN = 1;
	static const int TEAM_SIZE_MAX = 20;
	static const int TEAM_SIZE_DEFAULT = TEAM_SIZE_MAX;

	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final QueueRepository _queueRepository;
	final Router _router;

	Event _evnt;

	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String teamName;
	SelectionModel<int> teamSizeSelection = SelectionModel.single(selected: TEAM_SIZE_DEFAULT);
	bool acceptToc = false;
	bool hasError = false;

	String get eventName => _evnt.name;

	String get eventOpening =>
		null != _evnt.opening ? DateTimeFormatter.format(_evnt.opening)
			: 'någon gång i en avlägsen framtid';

	bool get hasOpeningTime => null != _evnt.opening;

	bool get isLoaded => null != _evnt;

	int get teamSize => teamSizeSelection.selectedValues.first;

	SelectionOptions<int> get teamSizeOptions => SelectionOptions.fromList(range(TEAM_SIZE_MIN, TEAM_SIZE_MAX + 1, 1).cast<int>().toList(growable: false));

	StartPage(this._clientFactory, this._eventRepository, this._queueRepository, this._router);

	@override
	Future<void> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			_evnt = await _eventRepository.getActiveEvent(client);
		} catch (e) {
			print('Failed to load active event: ${e.toString()}');
			hasError = true;
		}
	}

	Future<void> submitDetails() async {
		final candidate = BookingDetails(firstName, lastName, phoneNo, email, teamName, teamSize);
		CandidateResponse response;

		try {
			_clientFactory.clear();
			final client = _clientFactory.getClient();
			response = await _queueRepository.createCandidate(client, candidate);
		} catch (e) {
			print('Failed to create booking candidate: ${e.toString()}');
			hasError = true;
			return;
		}

		final state = CountdownState();
		state.update(response);

		await _router.navigateByUrl(ContentRoutes.countdown.toUrl());
	}

	String teamSizeToString(int size) {
		if(1 == size)
			return '1 person';
		else
			return '$size personer';
	}
}
