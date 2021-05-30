import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model/booking_payment_model.dart';
import 'package:quiver/strings.dart' as str show isEmpty;

import 'json_field.dart';

class BookingOverviewItem extends BookingPaymentModel {
  final String reference;
  final String subCruise;
  final String firstName;
  final String lastName;
  final String lunch;
  final int numberOfCabins;
  final bool isLocked;
  final DateTime updated;

  BookingOverviewItem(this.reference, this.subCruise, this.firstName, this.lastName, this.lunch, Decimal totalPrice, Decimal amountPaid,
      this.numberOfCabins, this.isLocked, this.updated)
      : super(totalPrice, amountPaid);

  factory BookingOverviewItem.fromMap(Map<String, dynamic> json) => BookingOverviewItem(
      json[REFERENCE],
      json[SUBCRUISE],
      json[FIRSTNAME],
      json[LASTNAME],
      json[LUNCH],
      Decimal.parse(json[TOTAL_PRICE].toString()),
      Decimal.parse(json[AMOUNT_PAID].toString()),
      json[NUMBER_OF_CABINS],
      json[IS_LOCKED],
      DateTime.parse(json[UPDATED]));

  String get lunchFormatted => str.isEmpty(lunch) ? '' : '$lunch:00';
}
