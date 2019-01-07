import 'dart:html' show window;

import '../model/candidate_response.dart';

class CountdownState {
	static const String CANDIDATE_ID = 'candidate_id';
	static const String COUNTDOWN = 'countdown';
	static const String COUNTDOWN_FROM = 'countdown_from';
	static const int SYNC_ERROR_TRESHOLD = 1000;

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

	CountdownState() {
		if (window.sessionStorage.containsKey(CANDIDATE_ID)
			&& window.sessionStorage.containsKey(COUNTDOWN)
			&& window.sessionStorage.containsKey(COUNTDOWN_FROM)) {
			try {
				candidateId = window.sessionStorage[CANDIDATE_ID];
				_countdown = int.parse(window.sessionStorage[COUNTDOWN]);
				_countdownFrom = DateTime.parse(window.sessionStorage[COUNTDOWN_FROM]);
			} catch (e) {
				print('Failed to initialize countdown state (corrupt data): ${e.toString()}');
				candidateId = null;
			}
		}
	}

	@override
	String toString() {
		final String twoDigitMinutes = inMinutes.remainder(Duration.minutesPerHour).toString().padLeft(2, '0');
		final String twoDigitSeconds = inSeconds.remainder(Duration.secondsPerMinute).toString().padLeft(2, '0');
		final String oneDigitMs = (inMilliseconds.remainder(Duration.millisecondsPerSecond) ~/ 100).toString();
		return '$inHours:$twoDigitMinutes:$twoDigitSeconds.$oneDigitMs';
	}

	void update(CandidateResponse response) {
		final countdownInMs = response.countdown;
		final syncError = countdownInMs - inMilliseconds;
		if (syncError.abs() > SYNC_ERROR_TRESHOLD) {
			print('Countdown sync error = ${syncError.toString()} ms.');
		}

		candidateId = response.id;
		_countdown = countdownInMs;
		_countdownFrom = DateTime.now();

		window.sessionStorage[CANDIDATE_ID] = response.id;
		window.sessionStorage[COUNTDOWN] = response.countdown.toString();
		window.sessionStorage[COUNTDOWN_FROM] = _countdownFrom.toIso8601String();
	}
}
