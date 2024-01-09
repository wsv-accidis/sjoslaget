import 'dart:convert';

import 'package:frontend_shared/model.dart' show PaymentSummary;
import 'package:frontend_shared/util/value_converter.dart';

import 'booking_pax.dart';
import 'json_field.dart';

class BookingSource {
  String reference;
  String firstName;
  String lastName;
  String email;
  String phoneNo;
  String teamName;
  String groupName;
  String specialRequest;
  String internalNotes;
  int discount;
  bool isLocked;
  DateTime confirmationSent;
  List<BookingPax> pax;
  PaymentSummary payment;

  BookingSource(
      this.reference,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNo,
      this.teamName,
      this.groupName,
      this.specialRequest,
      this.internalNotes,
      this.discount,
      this.isLocked,
      this.confirmationSent,
      this.pax,
      this.payment);

  factory BookingSource.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);

    final List<BookingPax> pax =
        map[PAX].map((dynamic value) => BookingPax.fromMap(value)).cast<BookingPax>().toList(growable: false);

    return BookingSource(
        map[REFERENCE],
        map[FIRSTNAME],
        map[LASTNAME],
        map[EMAIL],
        map[PHONE_NO],
        map[TEAM_NAME],
        map[GROUP_NAME],
        map[SPECIAL_REQUEST],
        map[INTERNAL_NOTES],
        map[DISCOUNT],
        map[IS_LOCKED],
        ValueConverter.parseDateTime(map[CONFIRMATION_SENT]),
        pax,
        PaymentSummary.fromMap(map[PAYMENT]));
  }

  String toJson() {
    final paxMap = pax.map((p) => p.toMap()).toList(growable: false);

    return json.encode({
      REFERENCE: reference,
      FIRSTNAME: firstName,
      LASTNAME: lastName,
      EMAIL: email,
      PHONE_NO: phoneNo,
      TEAM_NAME: teamName,
      GROUP_NAME: groupName,
      SPECIAL_REQUEST: specialRequest,
      INTERNAL_NOTES: internalNotes,
      PAX: paxMap
    });
  }
}
