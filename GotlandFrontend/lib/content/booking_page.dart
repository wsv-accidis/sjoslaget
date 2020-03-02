import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:quiver/iterables.dart';

import '../booking/booking_login_component.dart';
import '../booking/booking_routes.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/queue_repository.dart';
import '../model/booking_details.dart';
import '../model/candidate_response.dart';
import '../model/event.dart';
import '../model/team_size.dart';
import '../util/countdown_state.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'about_routes.dart';
import 'content_routes.dart';

@Component(
    selector: 'start-page',
    styleUrls: ['content_styles.css', 'booking_page.css', 'booking_styles.css'],
    templateUrl: 'booking_page.html',
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, routerDirectives, BookingLoginComponent, SpinnerWidget],
    providers: <dynamic>[materialProviders],
    exports: [AboutRoutes, ContentRoutes])
class BookingPage implements OnInit {
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
  int teamSize = TEAM_SIZE_DEFAULT;
  SelectionModel<int> teamSizeSelection = SelectionModel.single(selected: TEAM_SIZE_DEFAULT);
  bool acceptToc = false;
  bool acceptRules = false;
  bool hasError = false;

  String get eventName => _evnt.name;

  String get eventOpening => DateTimeFormatter.format(_evnt.opening);

  bool get isClosed => isLoaded && _evnt.isLocked;

  bool get isLoaded => null != _evnt;

  bool get isInCountdown => isLoaded && _evnt.isInCountdown;

  bool get isNotReady => isLoaded && !_evnt.isInCountdown && !_evnt.hasOpened && !_evnt.isLocked;

  bool get isOpen => isLoaded && _evnt.isOpenAndNotLocked;

  SelectionOptions<int> get teamSizeOptions => SelectionOptions.fromList(range(TEAM_SIZE_MIN, TEAM_SIZE_MAX + 1, 1).cast<int>().toList(growable: false));

  BookingPage(this._clientFactory, this._eventRepository, this._queueRepository, this._router);

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

    final state = CountdownState.empty();
    state.update(response);

    await _router.navigateByUrl(BookingRoutes.countdown.toUrl());
  }

  void teamSizeChanged(int size) {
    // We save the last set value because the user might unintentionally "unselect" the value
    // from the dropdown and leave it at null.
    if (null != size) {
      teamSize = size;
    }
  }

  String teamSizeToString(dynamic size) {
    if (1 == size)
      return '1 person';
    else
      return '$size personer';
  }
}
