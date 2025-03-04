import 'dart:convert';

import 'json_field.dart';

class PaidCapacity {
  final int eventCapacity;
  final int totalDayPax;
  final int totalDayPaxPaid;
  final int totalPax;
  final int totalPaxPaid;

  int get totalPercent => ((totalPax + totalDayPax) * 100 / eventCapacity).round();

  int get paidPercent =>
      totalPax + totalDayPax <= 0 ? 0 : ((totalPaxPaid + totalDayPaxPaid) * 100 / (totalPax + totalDayPax)).round();

  PaidCapacity(this.eventCapacity, this.totalPax, this.totalDayPax, this.totalPaxPaid, this.totalDayPaxPaid);

  factory PaidCapacity.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return PaidCapacity(map[EVENT_CAPACITY], map[TOTAL_PAX], map[TOTAL_DAY_PAX], map[TOTAL_PAX_PAID], map[TOTAL_DAY_PAX_PAID]);
  }
}
