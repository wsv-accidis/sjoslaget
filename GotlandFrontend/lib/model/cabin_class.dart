import 'package:decimal/decimal.dart';
import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class CabinClass {
	final int no;
	final String name;
	final String description;
	final int count;
	final Decimal pricePerPax;

	CabinClass(this.no, this.name, this.description, this.count, this.pricePerPax);

	factory CabinClass.fromMap(Map<String, dynamic> json) =>
		CabinClass(ValueConverter.toInt(json[NO]), json[NAME], json[DESCRIPTION], int.parse(json[COUNT].toString()), Decimal.parse(json[PRICE_PER_PAX].toString()));
}
