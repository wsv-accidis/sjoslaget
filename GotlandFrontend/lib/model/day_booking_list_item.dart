import 'package:frontend_shared/util.dart' show ValueConverter;

import 'json_field.dart';

class DayBookingListItem {
  DayBookingListItem(this.id, this.firstName, this.lastName, this.email, this.phoneNo, this.dob, this.food, this.typeId,
      this.paymentConfirmed, this.created, this.updated);

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String dob;
  final String food;
  final String typeId;
  final bool paymentConfirmed;
  final DateTime created;
  final DateTime updated;

  factory DayBookingListItem.fromMap(Map<String, dynamic> json) => DayBookingListItem(
      json[ID],
      json[FIRSTNAME],
      json[LASTNAME],
      json[EMAIL],
      json[PHONE_NO],
      json[DOB],
      json[FOOD],
      json[TYPE_ID],
      json[PAYMENT_CONFIRMED],
      ValueConverter.parseDateTime(json[CREATED]),
      ValueConverter.parseDateTime(json[UPDATED]));
}
