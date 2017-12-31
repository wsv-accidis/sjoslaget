import 'dart:convert';

import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class Event {
	String name;
	bool isOpen;
	DateTime opening;

	Event(this.name, this.isOpen, this.opening);

	factory Event.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new Event(map[NAME], map[IS_OPEN], ValueConverter.parseDateTime(map[OPENING]));
	}
}
