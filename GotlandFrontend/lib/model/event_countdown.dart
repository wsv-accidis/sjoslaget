import 'dart:convert';

import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class EventCountdown {
	DateTime opening;
	int countdown;

	EventCountdown(this.opening, this.countdown);

	factory EventCountdown.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return EventCountdown(ValueConverter.parseDateTime(map[OPENING]), map[COUNTDOWN]);
	}
}
