import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/post_list_item.dart';
import 'package:frontend_shared/util.dart';

import '../client/client_factory.dart';
import '../client/post_repository.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_post_page.dart';
import 'admin_routes.dart';

@Component(
    selector: 'admin-post-list-page',
    templateUrl: 'admin_post_list_page.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_post_list_page.css'],
    directives: <dynamic>[coreDirectives, routerDirectives, gotlandMaterialDirectives, SpinnerWidget],
    providers: <dynamic>[materialProviders],
    exports: <dynamic>[AdminRoutes])
class AdminPostListPage implements OnInit {
  static const ELLIPSIFY_LIMIT = 60;

  final Router _router;
  final ClientFactory _clientFactory;
  final PostRepository _postRepository;

  List<PostListItem> posts;

  bool get isLoading => null == posts;

  AdminPostListPage(this._clientFactory, this._postRepository, this._router);

  String ellipsify(String str) =>
      str.length > ELLIPSIFY_LIMIT ? '${str.substring(0, ELLIPSIFY_LIMIT).trimRight()}...' : str;

  String formatDateTime(DateTime dateTime) => DateTimeFormatter.format(dateTime);

  Future<void> createPost() async {
    await _router.navigateByUrl(AdminRoutes.postUrl(AdminPostPage.NEW_ID));
  }

  @override
  Future<void> ngOnInit() async {
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final client = _clientFactory.getClient();
      posts = await _postRepository.getList(client);
    } catch (e) {
      print('Failed to load list of posts: ${e.toString()}');
      // Just ignore this here, we will be stuck in the loading state until the user refreshes
    }
  }
}
