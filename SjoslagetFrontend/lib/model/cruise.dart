import 'dart:convert';

class Cruise {
	static const IS_LOCKED = 'IsLocked';
	static const NAME = 'Name';

	String name;
	bool isLocked;

	Cruise(this.name, this.isLocked);

	factory Cruise.fromJson(String json) {
		final Map<String, dynamic> map = JSON.decode(json);
		return new Cruise(map[NAME], map[IS_LOCKED]);
	}
}
