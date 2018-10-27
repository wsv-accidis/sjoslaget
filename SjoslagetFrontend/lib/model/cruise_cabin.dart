import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class CruiseCabin {
	final int capacity;
	final int count;
	final String description;
	final String id;
	final String name;
	final int pricePerPax;

	CruiseCabin(this.id, this.name, this.description, this.capacity, this.count, this.pricePerPax);

	factory CruiseCabin.fromMap(Map<String, dynamic> json) =>
		CruiseCabin(json[ID], json[NAME], json[DESCRIPTION], _toInt(json[CAPACITY]), _toInt(json[COUNT]), _toInt(json[PRICE_PER_PAX]));

	int get pricePerCabin => pricePerPax * capacity;

	static int _toInt(dynamic id) => ValueConverter.toInt(id);
}
