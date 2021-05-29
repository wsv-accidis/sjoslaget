import 'json_field.dart';

class SubCruise {
  String code;
  String name;

  SubCruise(this.code, this.name);

  factory SubCruise.fromMap(Map<String, dynamic> json) => SubCruise(json[CODE], json[NAME]);
}
