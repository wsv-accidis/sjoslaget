import 'json_field.dart';

class PostListItem {
  final String id;
  final String contentPreview;
  final DateTime created;
  final DateTime updated;

  PostListItem(this.id, this.contentPreview, this.created, this.updated);

  factory PostListItem.fromMap(Map<String, dynamic> json) => PostListItem(
      json[ID],
      json[CONTENT_PREVIEW],
      DateTime.parse(json[CREATED]),
      DateTime.parse(json[UPDATED]));
}
