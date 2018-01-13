import 'package:decimal/decimal.dart';

import 'json_field.dart';

class Trip {
	final String id;
	final String name;
	final DateTime departure;
	final Decimal price;

	Trip(this.id, this.name, this.departure, this.price);

	factory Trip.fromMap(Map<String, dynamic> json) =>
		new Trip(json[ID], json[NAME], DateTime.parse(json[DEPARTURE]), Decimal.parse(json[PRICE].toString()));
}
