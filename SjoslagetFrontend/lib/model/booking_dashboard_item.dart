import 'package:frontend_shared/util.dart' show DurationFormatter;

import 'json_field.dart';

class BookingDashboardItem {
  Duration _sinceUpdated;

  final String id;
  final String reference;
  final String subCruise;
  final String firstName;
  final String lastName;
  final DateTime created;
  final DateTime updated;
  final int numberOfCabins;
  final int numberOfPax;

  BookingDashboardItem(this.id, this.reference, this.subCruise, this.firstName, this.lastName, this.created, this.updated,
      this.numberOfCabins, this.numberOfPax);

  factory BookingDashboardItem.fromMap(Map<String, dynamic> json) => BookingDashboardItem(
      json[ID],
      json[REFERENCE],
      json[SUBCRUISE],
      json[FIRSTNAME],
      json[LASTNAME],
      DateTime.parse(json[CREATED]),
      DateTime.parse(json[UPDATED]),
      json[NUMBER_OF_CABINS],
      json[NUMBER_OF_PAX]);

  String get sinceUpdated {
    if (null == _sinceUpdated) return '';

    return DurationFormatter.formatCompact(_sinceUpdated);
  }

  void update(DateTime now) {
    _sinceUpdated = now.difference(updated);
  }
}
