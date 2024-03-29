import 'dart:convert';

import 'json_field.dart';
import 'solo_booking_view.dart';

class SoloBookingSource {
  SoloBookingSource(this.firstName, this.lastName, this.phoneNo, this.email, this.dob, this.food, this.gender);

  final String firstName;
  final String lastName;
  final String phoneNo;
  final String email;
  final String dob;
  final String food;
  final String gender;

  factory SoloBookingSource.fromSoloView(SoloBookingView solo) =>
      SoloBookingSource(solo.firstName, solo.lastName, solo.phoneNo, solo.email, solo.dob, solo.food, solo.gender);

  String toJson() => json.encode({
        FIRSTNAME: firstName,
        LASTNAME: lastName,
        PHONE_NO: phoneNo,
        EMAIL: email,
        DOB: dob,
        FOOD: food,
        GENDER: gender
      });
}
