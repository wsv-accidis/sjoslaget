import 'dart:convert';

import 'package:frontend_shared/util.dart';

import 'json_field.dart';
import 'solo_booking_source.dart';
import 'solo_booking_view.dart';

class DayBookingSource extends SoloBookingSource {
  DayBookingSource(this.reference, String firstName, String lastName, String phoneNo, String email, String dob,
      String food, String gender, this.typeId, this.paymentConfirmed, this.confirmationSent)
      : super(firstName, lastName, phoneNo, email, dob, food, gender);

  final String reference;
  final String typeId;
  final bool paymentConfirmed;
  final DateTime confirmationSent;

  factory DayBookingSource.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return DayBookingSource(
        map[REFERENCE],
        map[FIRSTNAME],
        map[LASTNAME],
        map[PHONE_NO],
        map[EMAIL],
        map[DOB],
        map[FOOD],
        map[GENDER],
        map[TYPE_ID],
        map[PAYMENT_CONFIRMED],
        ValueConverter.parseDateTime(map[CONFIRMATION_SENT]));
  }

  factory DayBookingSource.fromSoloView(SoloBookingView solo, String typeId) => DayBookingSource('', solo.firstName,
      solo.lastName, solo.phoneNo, solo.email, solo.dob, solo.food, solo.gender, typeId, false, null);

  @override
  String toJson() => json.encode({
        REFERENCE: reference,
        FIRSTNAME: firstName,
        LASTNAME: lastName,
        PHONE_NO: phoneNo,
        EMAIL: email,
        DOB: dob,
        FOOD: food,
        GENDER: gender,
        TYPE_ID: typeId,
        PAYMENT_CONFIRMED: paymentConfirmed
      });
}
