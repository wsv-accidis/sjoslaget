import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import '../../client.dart';
import '../../model/json_field.dart';
import '../../model/post_list_item.dart';
import '../../model/post_result.dart';
import '../../model/post_source.dart';

class PostRepositoryBase {
  final String _apiRoot;

  PostRepositoryBase(this._apiRoot);

  Future<void> deleteImage(Client client, String id) async {
    Response response;
    try {
      response = await client.delete('$_apiRoot/images/$id');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
  }

  Future<void> deletePost(Client client, String id) async {
    Response response;
    try {
      response = await client.delete('$_apiRoot/posts/$id');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
  }

  String getImageUrlById(String imageId) => '$_apiRoot/images/$imageId';

  Future<List<PostListItem>> getList(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/posts');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonResult = json.decode(response.body);
    return jsonResult
        .map((dynamic value) => PostListItem.fromMap(value))
        .toList(growable: false);
  }

  Future<PostSource> getPost(Client client, String id) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/posts/$id');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    return PostSource.fromJson(response.body);
  }

  Future<List<PostSource>> getWindow(
      Client client, int offset, int limit) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/posts/window/$offset/$limit');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonResult = json.decode(response.body);
    return jsonResult
        .map((dynamic value) => PostSource.fromMap(value))
        .toList(growable: false);
  }

  Future<PostResult> savePost(Client client, PostSource post) async {
    final headers = ClientUtil.createJsonHeaders();

    Response response;
    try {
      response = await client.post('$_apiRoot/posts',
          headers: headers, body: post.toJson());
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    return PostResult.fromJson(response.body);
  }

  Future<PostResult> uploadImage(
      Client client, String postId, Uint8List imageBytes) async {
    final headers = ClientUtil.createJsonHeaders();
    final source =
        json.encode({POST_ID: postId, IMAGE_BYTES: base64Encode(imageBytes)});

    Response response;
    try {
      response =
          await client.post('$_apiRoot/images', headers: headers, body: source);
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    return PostResult.fromJson(response.body);
  }
}
