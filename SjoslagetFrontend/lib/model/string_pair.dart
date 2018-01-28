import 'package:frontend_shared/util.dart';

import 'json_field.dart';

class KeyValuePair {
	final String key;
	final int value;

	KeyValuePair(this.key, this.value);

	factory KeyValuePair.fromMap(Map<String, dynamic> map) =>
		new KeyValuePair(map[KEY], ValueConverter.toInt(map[VALUE]));
}
