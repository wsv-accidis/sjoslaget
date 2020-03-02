import 'dart:convert';

import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class Event {
	String name;
	bool hasOpened;
	bool isOpenAndNotLocked;
	bool isInCountdown;
	bool isLocked;
	DateTime opening;

	Event(this.name, this.hasOpened, this.isOpenAndNotLocked, this.isInCountdown, this.isLocked, this.opening);

	factory Event.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return Event(map[NAME], map[HAS_OPENED], map[IS_OPEN_AND_NOT_LOCKED], map[IS_IN_COUNTDOWN], map[IS_LOCKED], ValueConverter.parseDateTime(map[OPENING]));
	}
}
