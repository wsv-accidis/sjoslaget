import 'dart:async';
import 'dart:math' show Random;
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model.dart';

import '../client/booking_exception.dart';
import '../client/client_factory.dart';
import '../client/queue_repository.dart';
import '../model/queue_response.dart';
import '../util/countdown_state.dart';

@Component(
	selector: 'countdown-page',
	styleUrls: const ['content_styles.css', 'countdown_page.css'],
	templateUrl: 'countdown_page.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives],
	providers: const <dynamic>[materialProviders]
)
class CountdownPage implements OnInit, OnDestroy {
	static const MAX_SUBMIT_ATTEMPTS = 3;
	static const PING_INTERVAL = 60000;
	static const RANDOM_DELAY_MIN = 5000;
	static const RANDOM_DELAY_MAX = 10000;
	static const TICK_INTERVAL = 100;

	final ClientFactory _clientFactory;
	final QueueRepository _queueRepository;
	final Router _router;

	final _countdown = new CountdownState();
	Timer _countdownTimer;
	Timer _pingTimer;
	final _random = new Random();

	BookingResult bookingResult;
	String countdownFormatted;
	bool hasBookingError = false;
	bool hasError = false;
	QueueResponse queueResponse;
	bool waitingForServer = false;

	bool get countdownIsElapsed => _countdown.isElapsed;

	bool get hasCreatedBooking => null != bookingResult;

	bool get shouldDisableButton => !countdownIsElapsed || waitingForServer;

	bool get shouldShowCountdown => !waitingForServer && !hasCreatedBooking && !hasBookingError;

	CountdownPage(this._clientFactory, this._queueRepository, this._router);

	void ngOnDestroy() {
		_cancelTimers();
	}

	Future<Null> ngOnInit() async {
		if (!_countdown.hasState) {
			_router.navigate(<dynamic>['/Content/Start']);
			return;
		}

		_tick(null);
		_countdownTimer = new Timer.periodic(new Duration(milliseconds: TICK_INTERVAL), _tick);

		await _ping(null);
		_pingTimer = new Timer.periodic(new Duration(milliseconds: PING_INTERVAL), _ping);
	}

	Future<Null> createBooking() async {
		try {
			final client = _clientFactory.getClient();
			bookingResult = await _queueRepository.toBooking(client, _countdown.candidateId);
			_clearErrors();
		} on BookingException catch (e) {
			// If we end up here the booking was created on the backend already, so
			// everything is OK after all
			print('Conflict when creating booking: ' + e.toString());
			hasBookingError = true;
		} catch (e) {
			// We have a queue position but failed to create a booking
			print('Failed to create booking: ' + e.toString());
			hasError = true;
		}
	}

	Future<Null> finishCreateBooking() async {
		await createBooking();
		if(null == bookingResult)
			return;

		try {
			await _clientFactory.authenticate(bookingResult.reference, bookingResult.password);
		} catch (e) {
			print('Booking was created but failed to authenticate: ' + e.toString());
			return;
		}

		_router.navigate(<dynamic>['/Booking/Booking']);
	}

	Future<Null> submitCandidate() async {
		_cancelTimers();
		_clearErrors();

		waitingForServer = true;
		try {
			int retries = 0;

			while (null == queueResponse && retries < MAX_SUBMIT_ATTEMPTS) {
				await trySubmitCandidate();
				retries++;
			}

			if (null != queueResponse) {
				// Add a random delay. This has NO impact on the queue position that this user
				// gets, as one has already been assigned. It only serves to reduce server load.
				final int delay = RANDOM_DELAY_MIN + _random.nextInt(RANDOM_DELAY_MAX - RANDOM_DELAY_MIN);
				print('Claimed queue position ' + queueResponse.placeInQueue.toString() + ', creating booking after ' + delay.toString() + ' ms.');
				await new Future<Null>.delayed(new Duration(milliseconds: delay), finishCreateBooking);
			} else {
				hasError = true;
			}
		} finally {
			waitingForServer = false;
		}
	}

	Future<Null> trySubmitCandidate() async {
		try {
			final client = _clientFactory.getClient();
			queueResponse = await _queueRepository.go(client, _countdown.candidateId);
		}
		on BookingException catch (e) {
			print('Failed to submit candidate because countdown had not elapsed!');
		} catch (e) {
			print('Failed to submit candidate: ' + e.toString());
		}
	}

	void _cancelTimers() {
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

	Future<Null> _ping(Timer ignored) async {
		try {
			final client = _clientFactory.getClient();
			final response = await _queueRepository.ping(client, _countdown.candidateId);
			_countdown.update(response);
		} on BookingException catch (e) {
			// TODO Show inactivity error message
			print('Failed to ping queue because candidate had timed out.');
			_cancelTimers();
		} catch (e) {
			print('Failed to ping queue: ' + e.toString());
		}
	}

	void _tick(Timer ignored) {
		countdownFormatted = _countdown.toString();
	}
}
