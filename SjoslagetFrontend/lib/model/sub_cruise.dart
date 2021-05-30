import 'json_field.dart';

class SubCruise {
  String code;
  String name;

  SubCruise(this.code, this.name);

  factory SubCruise.fromMap(Map<String, dynamic> json) => SubCruise(json[CODE], json[NAME]);

  static String codeToLabel(String code) {
    switch (code) {
      case 'A':
        return '1';
      case 'B':
        return '2';
      case 'AB':
        return '1+2';
      default:
        return '-';
    }
  }

  static int codeToOrdinal(String code) {
    switch (code) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'AB':
        return 2;
      default:
        return 99;
    }
  }
}
