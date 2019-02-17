import 'dart:html' show window;

import '../model/candidate_response.dart';

class CountdownState {
	static const String CANDIDATE_ID = 'candidate_id';
	static const String COUNTDOWN = 'countdown';
	static const String COUNTDOWN_FROM = 'countdown_from';
	static const int SYNC_ERROR_THRESHOLD = 1000;

	int _countdown = 0;
	DateTime _countdownFrom;

	int get _currentOffsetMs => (DateTime.now().difference(_countdownFrom)).inMilliseconds;

	String candidateId;

	int get inHours => inMilliseconds ~/ Duration.millisecondsPerHour;

	int get inMilliseconds => (_countdown <= 0 || _currentOffsetMs >= _countdown) ? 0 : _countdown - _currentOffsetMs;

	int get inMinutes => inMilliseconds ~/ Duration.millisecondsPerMinute;

	int get inSeconds => inMilliseconds ~/ Duration.millisecondsPerSecond;

	bool get isElapsed => inMilliseconds == 0;

	bool get hasState => null != candidateId && candidateId.isNotEmpty;

	CountdownState();

	factory CountdownState.fromSession() {
		final state = CountdownState();

		if (window.sessionStorage.containsKey(CANDIDATE_ID)
			&& window.sessionStorage.containsKey(COUNTDOWN)
			&& window.sessionStorage.containsKey(COUNTDOWN_FROM)) {
			try {
				state.candidateId = window.sessionStorage[CANDIDATE_ID];
				state._countdown = int.parse(window.sessionStorage[COUNTDOWN]);
				state._countdownFrom = DateTime.parse(window.sessionStorage[COUNTDOWN_FROM]);
			} catch (e) {
				print('Failed to initialize countdown state (corrupt data): ${e.toString()}');
				state.candidateId = null;
			}
		}

		return state;
	}

	factory CountdownState.empty() => CountdownState();

	@override
	String toString() {
		final String twoDigitMinutes = inMinutes.remainder(Duration.minutesPerHour).toString().padLeft(2, '0');
		final String twoDigitSeconds = inSeconds.remainder(Duration.secondsPerMinute).toString().padLeft(2, '0');
		final String oneDigitMs = (inMilliseconds.remainder(Duration.millisecondsPerSecond) ~/ 100).toString();
		return '$inHours:$twoDigitMinutes:$twoDigitSeconds.$oneDigitMs';
	}

	void update(CandidateResponse response) {
		_update(response.countdown);
		candidateId = response.id;

		window.sessionStorage[CANDIDATE_ID] = response.id;
		window.sessionStorage[COUNTDOWN] = response.countdown.toString();
		window.sessionStorage[COUNTDOWN_FROM] = _countdownFrom.toIso8601String();
	}

	void updateCountdown(int countdownMs) {
		_update(countdownMs);
	}

	void _update(int countdownMs) {
		final syncError = countdownMs - inMilliseconds;
		if (syncError.abs() > SYNC_ERROR_THRESHOLD) {
			print('Countdown sync error = ${syncError.toString()} ms.');
		}

		_countdown = countdownMs;
		_countdownFrom = DateTime.now();
	}
}
