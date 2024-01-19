import 'dart:convert';

import '../util/value_converter.dart';
import 'json_field.dart';

class PostSource {
  String id;
  String content;
  final String contentHtml;
  final DateTime created;
  final DateTime updated;
  final List<String> images;

  PostSource(this.id, this.content, this.contentHtml, this.created,
      this.updated, this.images);

  factory PostSource.empty() => PostSource('', '', '', null, null, <String>[]);

  factory PostSource.fromMap(Map<String, dynamic> map) =>
      PostSource(
          map[ID],
          map[CONTENT],
          map[CONTENT_HTML],
          ValueConverter.parseDateTime(map[CREATED]),
          ValueConverter.parseDateTime(map[UPDATED]),
          map[IMAGES].cast<String>().toList(growable: false));

  factory PostSource.fromJson(String jsonStr) {
    final Map<String, dynamic> map = json.decode(jsonStr);
    return PostSource.fromMap(map);
  }

  String toJson() => json.encode({ID: id, CONTENT: content});
}
