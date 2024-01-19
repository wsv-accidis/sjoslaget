import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/post_image_view.dart';
import 'package:frontend_shared/model/post_source.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';
import 'package:frontend_shared/widget/post_view.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../client/client_factory.dart';
import '../client/post_repository.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(selector: 'admin-post-page', templateUrl: 'admin_post_page.html', styleUrls: [
  '../content/content_styles.css',
  'admin_styles.css',
  'admin_post_page.css'
], directives: <dynamic>[
  coreDirectives,
  routerDirectives,
  formDirectives,
  gotlandMaterialDirectives,
  ModalDialog,
  SpinnerWidget,
  PostView
], providers: <dynamic>[
  materialProviders
], exports: <dynamic>[
  AdminRoutes
])
class AdminPostPage implements OnActivate {
  static const NEW_ID = 'ny';

  final ClientFactory _clientFactory;
  final PostRepository _postRepository;
  final Router _router;

  @ViewChild('deletePostDialog')
  ModalDialog deletePostDialog;

  @ViewChild('uploadImageInput')
  FileUploadInputElement uploadImageElement;

  bool isSaving = false;
  String loadingError;
  PostSource post;
  List<PostImageView> images = <PostImageView>[];

  bool get isLoading => null == post;

  bool get isSaved => null != post && isNotEmpty(post.id);

  bool get hasImages => null != post && post.images.isNotEmpty;

  bool get hasLoadingError => isNotEmpty(loadingError);

  bool get hasText => null != post && post.content.isNotEmpty;

  AdminPostPage(this._clientFactory, this._postRepository, this._router);

  Future<void> deletePost() async {
    if (isSaving || !isSaved) return;
    if (!await deletePostDialog.openAsync()) return;

    isSaving = true;

    try {
      final client = _clientFactory.getClient();
      await _postRepository.deletePost(client, post.id);
    } catch (e) {
      print('Failed to delete post: ${e.toString()}');
    } finally {
      isSaving = false;
    }

    await _router.navigateByUrl(AdminRoutes.postList.toUrl());
  }

  @override
  Future<void> onActivate(_, RouterState routerState) async {
    final String id = routerState.parameters['id'];
    if (NEW_ID == id) {
      post = PostSource.empty();
    } else {
      await _refresh(id);
    }
  }

  Future<void> savePost() async {
    if (isSaving) return;

    isSaving = true;
    loadingError = null;

    try {
      final client = _clientFactory.getClient();
      // (1) Delete any images pending deletion
      if (isSaved && hasImages) {
        images.where((i) => i.delete).forEach((i) {
          _postRepository.deleteImage(client, i.id);
        });
      }
      // (2) Update the post text
      final result = await _postRepository.savePost(client, post);
      post.id = result.id;
      // (3) Upload any image pending upload
      if (_hasUploadableImage) {
        await _uploadImage();
        uploadImageElement.value = '';
      }
      // (4) Reload post to get preview and images
      if (!hasLoadingError) {
        await _refresh(post.id);
      }
    } catch (e) {
      print('Failed to save post: ${e.toString()}');
      loadingError = 'Någonting gick fel och nyheten kunde inte sparas. Ladda om sidan och försök igen.';
    } finally {
      isSaving = false;
    }
  }

  String uniqueImageId(String id) => 'image-$id';

  bool get _hasUploadableImage => uploadImageElement.files?.isNotEmpty;

  Future<Uint8List> _readImageBytes() async {
    final blob = uploadImageElement.files[0];
    final reader = FileReader();
    reader.readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    return reader.result;
  }

  Future<void> _refresh(String postId) async {
    loadingError = null;
    try {
      final client = _clientFactory.getClient();
      post = await _postRepository.getPost(client, postId);
      images = post.images.map((imageId) => PostImageView(imageId, _postRepository.getImageUrlById(imageId))).toList();
    } catch (e) {
      print('Failed to load post: ${e.toString()}');
      loadingError = 'Någonting gick fel och nyheten kunde inte hämtas. Ladda om sidan och försök igen.';
    }
  }

  Future<void> _uploadImage() async {
    try {
      final imageBytes = await _readImageBytes();
      final client = _clientFactory.getClient();
      await _postRepository.uploadImage(client, post.id, imageBytes);
    } catch (e) {
      print('Failed to upload image: ${e.toString()}');
      loadingError = 'Någonting gick fel och bilden kunde inte laddas upp. Försök igen.';
    }
  }
}
