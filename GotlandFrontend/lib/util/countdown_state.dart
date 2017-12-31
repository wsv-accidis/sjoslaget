import 'dart:html' show window;

import '../model/candidate_response.dart';

class CountdownState {
	static const CANDIDATE_ID = 'candidate_id';
	static const COUNTDOWN = 'countdown';
	static const COUNTDOWN_FROM = 'countdown_from';

	int _countdown;
	DateTime _countdownFrom;

	String candidateId;

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

	void update(CandidateResponse response) {
		candidateId = response.id;
		_countdown = response.countdown;
		_countdownFrom = new DateTime.now();

		window.sessionStorage[CANDIDATE_ID] = candidateId;
		window.sessionStorage[COUNTDOWN] = _countdown.toString();
		window.sessionStorage[COUNTDOWN_FROM] = _countdownFrom.toIso8601String();
	}
}
