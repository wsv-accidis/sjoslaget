import 'dart:convert';

import 'json_field.dart';

class Cruise {
	String name;
	bool isLocked;

	Cruise(this.name, this.isLocked);

	factory Cruise.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new Cruise(map[NAME], map[IS_LOCKED]);
	}
}
