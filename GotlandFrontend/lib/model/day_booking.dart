import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class DayBooking {
  DayBooking(this.id, this.firstName, this.lastName, this.email, this.phoneNo, this.dob, this.food, this.type, this.paymentConfirmed, this.created);

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String dob;
  final String food;
  final String type;
  final bool paymentConfirmed;
  final DateTime created;

  factory DayBooking.fromMap(Map<String, dynamic> json) =>
      DayBooking(json[ID], json[FIRSTNAME], json[LASTNAME], json[EMAIL], json[PHONE_NO], json[DOB], json[FOOD], json[TYPE_ID], json[PAYMENT_CONFIRMED], ValueConverter.parseDateTime(json[CREATED]));
}
