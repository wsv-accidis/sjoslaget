import 'dart:convert';

import 'json_field.dart';

class DayBookingCapacity {
  int capacity;
  int count;

  DayBookingCapacity(this.capacity, this.count);

  factory DayBookingCapacity.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return DayBookingCapacity(map[CAPACITY], map[COUNT]);
  }
}
