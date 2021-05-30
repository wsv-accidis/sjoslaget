import 'json_field.dart';

class BookingPaxItem {
  String cabinType;
  final String cabinTypeId;
  final String reference;
  final String subCruise;
  String group;
  final String firstName;
  final String lastName;
  final String gender;
  final String dob;
  final String nationality;
  final int years;

  BookingPaxItem(this.cabinTypeId, this.reference, this.subCruise, this.group, this.firstName, this.lastName, this.gender, this.dob,
      this.nationality, this.years);

  factory BookingPaxItem.fromMap(Map<String, dynamic> json) => BookingPaxItem(json[CABIN_TYPE_ID], json[REFERENCE], json[SUBCRUISE],
      json[GROUP], json[FIRSTNAME], json[LASTNAME], json[GENDER], json[DOB], json[NATIONALITY], json[YEARS]);

  String get name => '$firstName $lastName';
}
