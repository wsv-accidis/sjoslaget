import 'dart:convert';

import 'json_field.dart';

class CandidateResponse {
	String id;
	int queueSize;
	int countdown;

	CandidateResponse(this.id, this.queueSize, this.countdown);

	factory CandidateResponse.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new CandidateResponse(map[ID], map[QUEUE_SIZE], map[COUNTDOWN]);
	}
}
