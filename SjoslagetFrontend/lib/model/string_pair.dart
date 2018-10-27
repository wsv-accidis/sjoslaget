import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class KeyValuePair {
	final String key;
	final int value;

	KeyValuePair(this.key, this.value);

	factory KeyValuePair.fromMap(Map map) =>
		KeyValuePair(map[KEY], ValueConverter.toInt(map[VALUE]));
}
