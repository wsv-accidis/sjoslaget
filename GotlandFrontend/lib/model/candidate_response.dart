import 'dart:convert';

import 'json_field.dart';

class CandidateResponse {
	String id;
	int queueSize;
	int countdown;

	CandidateResponse(this.id, this.queueSize, this.countdown);

	factory CandidateResponse.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return CandidateResponse(map[ID], map[QUEUE_SIZE], map[COUNTDOWN]);
	}
}
