import 'package:angular/angular.dart';

import '../client/client_factory_base.dart';
import '../client/repository/post_repository_base.dart';
import '../model/post_image_view.dart';
import '../model/post_source.dart';

class PostFeedBase implements OnInit {
  static const POST_LOAD_INCREMENT = 5;

  final ClientFactoryBase _clientFactory;
  final PostRepositoryBase _postRepository;

  bool isLoading = false;
  bool noMorePosts = false;
  List<PostSource> posts;

  bool get hasPosts => null != posts && posts.isNotEmpty;

  PostFeedBase(this._clientFactory, this._postRepository);

  @override
  Future<void> ngOnInit() async {
    posts = <PostSource>[];
    await loadMore();
  }

  Future<void> loadMore() async {
    isLoading = true;
    noMorePosts = false;

    try {
      final client = _clientFactory.getClient();
      final morePosts = await _postRepository.getWindow(
          client, posts.length, POST_LOAD_INCREMENT);
      posts.addAll(morePosts);

      if (morePosts.length < POST_LOAD_INCREMENT) {
        noMorePosts = true;
      }
    } catch (e) {
      print('Failed to load news feed: ${e.toString()}');
    } finally {
      isLoading = false;
    }
  }

  List<PostImageView> getImagesFor(PostSource post) => post.images
      .map((imageId) =>
          PostImageView(imageId, _postRepository.getImageUrlById(imageId)))
      .toList(growable: false);
}
