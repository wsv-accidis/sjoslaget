import 'package:angular/angular.dart';
import 'package:frontend_shared/widget/post_feed_base.dart';
import 'package:frontend_shared/widget/post_view.dart';

import '../client/client_factory.dart';
import '../client/post_repository.dart';

@Component(
    selector: 'post-feed',
    styleUrls: ['../content/content_styles.css', 'post_feed.css'],
    templateUrl: 'post_feed.html',
    directives: <dynamic>[coreDirectives, PostView])
class PostFeed extends PostFeedBase {
  PostFeed(ClientFactory clientFactory, PostRepository postRepository) : super(clientFactory, postRepository);
}
