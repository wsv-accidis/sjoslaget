import 'dart:convert';

import 'json_field.dart';

class Challenge {
  String challenge;

  Challenge(this.challenge);

  factory Challenge.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return Challenge(map[CHALLENGE]);
  }
}
