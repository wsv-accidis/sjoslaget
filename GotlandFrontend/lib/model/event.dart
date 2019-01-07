import 'dart:convert';

import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class Event {
	String name;
	bool isOpen;
	DateTime opening;

	Event(this.name, this.isOpen, this.opening);

	factory Event.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return Event(map[NAME], map[IS_OPEN], ValueConverter.parseDateTime(map[OPENING]));
	}
}
