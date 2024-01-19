import 'dart:convert';

import 'json_field.dart';

class PostResult {
  final String id;

  PostResult(this.id);

  factory PostResult.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return new PostResult(map[ID]);
  }
}
