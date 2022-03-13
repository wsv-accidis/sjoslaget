import 'package:decimal/decimal.dart';
import 'json_field.dart';

class DayBookingType {
  DayBookingType(this.id, this.title, this.isMember, this.price);

  final String id;
  final String title;
  final bool isMember;
  final Decimal price;

  factory DayBookingType.fromMap(Map<String, dynamic> json) =>
      DayBookingType(json[ID], json[TITLE], json[IS_MEMBER], Decimal.parse(json[PRICE].toString()));
}
