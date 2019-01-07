import 'dart:convert';

import 'json_field.dart';

class QueueResponse {
	int placeInQueue;

	QueueResponse(this.placeInQueue);

	factory QueueResponse.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return QueueResponse(map[PLACE_IN_QUEUE]);
	}
}
