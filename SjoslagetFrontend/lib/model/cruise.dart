import 'dart:convert';

import 'json_field.dart';

class Cruise {
	String name;
	bool isLocked = false;

	Cruise(this.name, this.isLocked);

	factory Cruise.fromJson(String jsonStr) {
		final Map<String, dynamic> map = json.decode(jsonStr);
		return Cruise(map[NAME], map[IS_LOCKED]);
	}
}
