import 'package:decimal/decimal.dart';
import 'json_field.dart';

class DayBookingType {
  DayBookingType(this.id, this.title, this.price);

  final String id;
  final String title;
  final Decimal price;

  factory DayBookingType.fromMap(Map<String, dynamic> json) => DayBookingType(json[ID], json[TITLE], Decimal.parse(json[PRICE].toString()));
}
