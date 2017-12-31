import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

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
	static const TICK_INTERVAL = 100;

	final ClientFactory _clientFactory;
	final QueueRepository _queueRepository;
	final Router _router;

	final _countdown = new CountdownState();
	Timer _countdownTimer;
	Timer _pingTimer;
	int _submitAttempts = 0;

	String countdownFormatted;
	QueueResponse queueResponse;
	bool waitingForResponse = false;

	bool get countdownIsElapsed => _countdown.isElapsed;

	bool get hasResponse => null != queueResponse;

	bool get shouldShowCountdown => !waitingForResponse && !hasResponse;

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

	Future<Null> submitCandidate() async {
		waitingForResponse = true;
		while (waitingForResponse) {
			await trySubmitCandidate();
		}
	}

	Future<Null> trySubmitCandidate() async {
		if (_submitAttempts++ > MAX_SUBMIT_ATTEMPTS) {
			// Gave up, if we couldn't do this after several attempts it's a lost cause
			throw new BookingException();
		}

		try {
			final client = _clientFactory.getClient();
			queueResponse = await _queueRepository.go(client, _countdown.candidateId);
			waitingForResponse = false;
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
