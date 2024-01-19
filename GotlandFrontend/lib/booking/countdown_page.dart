import 'dart:async';
import 'dart:math' show Random;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:quiver/strings.dart' show isEmpty;

import '../booking/booking_routes.dart';
import '../client/booking_exception.dart';
import '../client/client_factory.dart';
import '../client/queue_repository.dart';
import '../content/content_routes.dart';
import '../model/queue_response.dart';
import '../util/countdown_state.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';

@Component(
    selector: 'countdown-page',
    styleUrls: ['../content/content_styles.css', 'countdown_page.css'],
    templateUrl: 'countdown_page.html',
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, routerDirectives, SpinnerWidget],
    providers: <dynamic>[materialProviders],
    exports: [ContentRoutes])
class CountdownPage implements OnInit, OnDestroy {
  static const int BUTTON_CYCLE_INTERVAL = 10000;
  static const int MAX_SUBMIT_ATTEMPTS = 3;
  static const int PING_INTERVAL = 60000;
  static const int RANDOM_DELAY_MIN = 5000;
  static const int RANDOM_DELAY_MAX = 30000;
  static const int TICK_INTERVAL = 100;

  static const List<String> BUTTON_TEXT = <String>[
    'Klicka här när nedräkningen når noll',
    '...så får du en kaka (inte så troligt)',
    'Nu till lite roliga fakta om Gotland!',
    'Visste du att Gotland inte är Sveriges fårtätaste län?',
    'Det finns nämligen inga får på Gotland.',
    'Däremot finns det 35 000 lamm.',
    'Visste du? Du gör ingen nytta att glo länge på nedräkningen...',
    'Det kan till och med orsaka hjärnskador,',
    'att läsa en massa text som förmodligen skrevs på fyllan...',
    'av en teknolog med på tok för lite att göra.',
    'Det var en gång en flicka,',
    'som red uppå ett svin...',
    'Den här texten blev censurerad',
    'men sången var ändå fin...',
    'Dina föräldrar kanske minns den?',
    'Vi vill från avdelningen för drycker och gastronomi...',
    'meddela att årtusendets bästa spritsorter är utsedda!',
    'Det är Minttu och Fireball.',
    '...Va? Håller du inte med?',
    'Det finns konstiga människor som föredrar Fernet...',
    'Alltså, de som inte gör det kan också vara konstiga',
    'Pengarna räcker ju längre om man inte super alls...',
    'Men vem bryr sig?',
    'Vi hade tänkt ha lite AG-historia här',
    'Men en viss äldre arrangör är väldigt seg,',
    'på att kläcka ur sig hur det hela började...',
    'Så det blev inget av den planen.',
    'Ett år senare har fortfarande ingenting hänt.',
    'På tal om alkohol så... Varm och kall? Någon?',
    'Jag har för mig att det har funnits hela AG-lag...',
    'dedikerade till enbart Varm och kall.',
    'Oklart om de till slut insåg att en och samma dricka...',
    'i fyra dagar, kan bli lite enahanda.',
    'Läser någon faktiskt det här tramset...?',
    'Nu till ett recept på Hallongrottor:',
    'Tag 4 1/2 dl vetemjöl,',
    '1 dl socker,',
    '1 tsk bakpulver,',
    '2 tsk vaniljsocker,',
    '200 g smör',
    'Sätt ugnen på 200 grader C.',
    'Blanda alla torra ingredienser i en skål.',
    'Skär smöret i småbitar och tillsätt det.',
    'Knåda ihop hela skiten till en deg.',
    'Forma degen till små bollar, som en pingisboll typ.',
    'Lägg bollarna i muffinsformar på plåtar.',
    'Gör en fördjupning i varje kaka och klicka i sylt.',
    'Grädda mitt i ugnen i tio minuter.',
    'WOW! Du har just värpt ett gäng hallongrottor.',
  ];
  static const String BUTTON_TEXT_FINAL = 'KÖR KÖR KÖR KÖR KÖR KÖR NU NU NU NU!!!11';

  final ClientFactory _clientFactory;
  final QueueRepository _queueRepository;
  final Router _router;
  final TempCredentialsStore _tempCredentialsStore;

  BookingResult _bookingResult;
  int _buttonTextIndex = 0;
  Timer _buttonTimer;
  final _countdown = CountdownState.fromSession();
  Timer _countdownTimer;
  Timer _pingTimer;
  QueueResponse _queueResponse;
  final _random = Random();

  String buttonText = '';
  String countdownFormatted;
  String existingBookingRef = '';
  bool hasBookingError = false;
  bool hasError = false;
  bool waitingForServer = false;

  bool get countdownIsElapsed => _countdown.isElapsed;

  bool get hasCreatedBooking => null != _bookingResult;

  bool get shouldDisableButton => !countdownIsElapsed || waitingForServer;

  bool get shouldShowCountdown => !waitingForServer && !hasCreatedBooking && !hasBookingError;

  CountdownPage(this._clientFactory, this._queueRepository, this._router, this._tempCredentialsStore);

  @override
  void ngOnDestroy() {
    _cancelTimers();
  }

  @override
  Future<void> ngOnInit() async {
    if (!_countdown.hasState) {
      await _router.navigateByUrl(ContentRoutes.start.toUrl());
      return;
    }

    _updateButton(null);
    _buttonTimer = Timer.periodic(const Duration(milliseconds: BUTTON_CYCLE_INTERVAL), _updateButton);

    _tick(null);
    _countdownTimer = Timer.periodic(const Duration(milliseconds: TICK_INTERVAL), _tick);

    await _ping(null);
    _pingTimer = Timer.periodic(const Duration(milliseconds: PING_INTERVAL), _ping);

    if (countdownIsElapsed) {
      print('Countdown has already elapsed, go directly to booking.');
      await submitCandidate();
    }
  }

  Future<void> createBooking() async {
    try {
      final client = _clientFactory.getClient();
      _bookingResult = await _queueRepository.toBooking(client, _countdown.candidateId);
      _clearErrors();
    } catch (e) {
      // We have a queue position but failed to create a booking
      print('Failed to create booking: ${e.toString()}');
      hasError = true;
    }

    if (null == _bookingResult) return;
    if (isEmpty(_bookingResult.password)) {
      print('Booking already exists with ref: ${_bookingResult.reference}.');
      hasBookingError = true;
      existingBookingRef = _bookingResult.reference;
      return;
    }

    _tempCredentialsStore.save(_bookingResult);

    try {
      await _clientFactory.authenticate(_bookingResult.reference, _bookingResult.password);
    } catch (e) {
      print('Booking was created but failed to authenticate: ${e.toString()}');
      hasError = true;
      return;
    }

    await _router.navigateByUrl(BookingRoutes.editBooking.toUrl());
  }

  Future<void> submitCandidate() async {
    _cancelTimers();
    _clearErrors();

    if (waitingForServer) {
      return;
    }

    waitingForServer = true;
    try {
      int retries = 0;

      while (null == _queueResponse && retries < MAX_SUBMIT_ATTEMPTS) {
        await trySubmitCandidate();
        retries++;
      }

      if (null != _queueResponse) {
        // Add a random delay. This has NO impact on the queue position that this user
        // gets, as one has already been assigned. It only serves to reduce server load.
        final int delay = RANDOM_DELAY_MIN + _random.nextInt(RANDOM_DELAY_MAX - RANDOM_DELAY_MIN);
        print(
            'Claimed queue position ${_queueResponse.placeInQueue.toString()}, creating booking after ${delay.toString()} ms.');
        await Future<void>.delayed(Duration(milliseconds: delay), createBooking);
      } else {
        hasError = true;
      }
    } finally {
      waitingForServer = false;
    }
  }

  Future<void> trySubmitCandidate() async {
    try {
      final client = _clientFactory.getClient();
      _queueResponse = await _queueRepository.go(client, _countdown.candidateId);
    } on BookingException {
      print('Failed to submit candidate because countdown had not elapsed!');
    } catch (e) {
      print('Failed to submit candidate: ${e.toString()}');
    }
  }

  void _cancelTimers() {
    if (null != _buttonTimer) {
      _buttonTimer.cancel();
      _buttonTimer = null;
    }
    if (null != _countdownTimer) {
      _countdownTimer.cancel();
      _countdownTimer = null;
    }
    if (null != _pingTimer) {
      _pingTimer.cancel();
      _pingTimer = null;
    }
  }

  void _clearErrors() {
    hasBookingError = false;
    hasError = false;
  }

  Future<void> _ping(Timer ignored) async {
    try {
      final client = _clientFactory.getClient();
      final response = await _queueRepository.ping(client, _countdown.candidateId);
      _countdown.update(response);
    } on BookingException {
      print('Failed to ping queue because candidate had timed out.');
      _cancelTimers();
      await _router.navigateByUrl(ContentRoutes.booking.toUrl());
    } catch (e) {
      print('Failed to ping queue: ${e.toString()}');
    }
  }

  void _tick(Timer ignored) {
    countdownFormatted = _countdown.toString();

    if (countdownIsElapsed) {
      buttonText = BUTTON_TEXT_FINAL;
    }
  }

  void _updateButton(Timer ignored) {
    if (!countdownIsElapsed) {
      buttonText = BUTTON_TEXT[_buttonTextIndex];
      _buttonTextIndex = (1 + _buttonTextIndex) % BUTTON_TEXT.length;
    } else {
      buttonText = BUTTON_TEXT_FINAL;
    }
  }
}
