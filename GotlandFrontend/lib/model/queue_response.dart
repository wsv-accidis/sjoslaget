import 'dart:convert';

import 'json_field.dart';

class QueueResponse {
	int placeInQueue;

	QueueResponse(this.placeInQueue);

	factory QueueResponse.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new QueueResponse(map[PLACE_IN_QUEUE]);
	}
}
