import 'dart:convert';

import 'json_field.dart';
import 'solo_booking_source.dart';
import 'solo_view.dart';

class ExternalBookingSource extends SoloBookingSource {
  ExternalBookingSource(String firstName, String lastName, String phoneNo, String email, String dob, String food, String gender, this.type) : super(firstName, lastName, phoneNo, email, dob, food, gender);

  factory ExternalBookingSource.fromSoloView(SoloView solo, String type) => ExternalBookingSource(solo.firstName, solo.lastName, solo.phoneNo, solo.email, solo.dob, solo.food, solo.gender, type);

  final String type;

  @override
  String toJson() => json.encode({FIRSTNAME: firstName, LASTNAME: lastName, PHONE_NO: phoneNo, EMAIL: email, DOB: dob, FOOD: food, GENDER: gender, TYPE_ID: type});
}
