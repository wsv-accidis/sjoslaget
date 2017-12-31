import 'dart:html' show window;

import '../model/candidate_response.dart';

class CountdownState {
	static const CANDIDATE_ID = 'candidate_id';
	static const COUNTDOWN = 'countdown';
	static const COUNTDOWN_FROM = 'countdown_from';
	static const SYNC_ERROR_TRESHOLD = 1000;

	int _countdown = 0;
	DateTime _countdownFrom;

	String candidateId;

	int get _currentOffsetMs {
		return (new DateTime.now().difference(_countdownFrom)).inMilliseconds;
	}

	int get inHours => inMilliseconds ~/ Duration.MILLISECONDS_PER_HOUR;

	int get inMilliseconds => (_countdown <= 0 || _currentOffsetMs >= _countdown) ? 0 : _countdown - _currentOffsetMs;

	int get inMinutes => inMilliseconds ~/ Duration.MILLISECONDS_PER_MINUTE;

	int get inSeconds => inMilliseconds ~/ Duration.MILLISECONDS_PER_SECOND;

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
				print('Failed to initialize countdown state (corrupt data): ' + e.toString());
				candidateId = null;
			}
		}
	}

	String toString() {
		String twoDigitMinutes = inMinutes.remainder(Duration.MINUTES_PER_HOUR).toString().padLeft(2, '0');
		String twoDigitSeconds = inSeconds.remainder(Duration.SECONDS_PER_MINUTE).toString().padLeft(2, '0');
		String oneDigitMs = (inMilliseconds.remainder(Duration.MILLISECONDS_PER_SECOND) ~/ 100).toString();
		return "$inHours:$twoDigitMinutes:$twoDigitSeconds.$oneDigitMs";
	}

	void update(CandidateResponse response) {
		final countdownInMs = response.countdown;
		final syncError = countdownInMs - inMilliseconds;
		if (syncError.abs() > SYNC_ERROR_TRESHOLD) {
			print('Countdown sync error = ' + syncError.toString() + ' ms.');
		}

		candidateId = response.id;
		_countdown = countdownInMs;
		_countdownFrom = new DateTime.now();

		window.sessionStorage[CANDIDATE_ID] = response.id;
		window.sessionStorage[COUNTDOWN] = response.countdown.toString();
		window.sessionStorage[COUNTDOWN_FROM] = _countdownFrom.toIso8601String();
	}
}
