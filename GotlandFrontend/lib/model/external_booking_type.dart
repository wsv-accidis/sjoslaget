import 'package:decimal/decimal.dart';
import 'json_field.dart';

class ExternalBookingType {
	ExternalBookingType(this.id, this.title, this.price);

	final String id;
	final String title;
	final Decimal price;

	factory ExternalBookingType.fromMap(Map<String, dynamic> json) =>
		ExternalBookingType(json[ID], json[TITLE], Decimal.parse(json[PRICE].toString()));
}
