import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../widgets/post_feed.dart';
import 'about_routes.dart';
import 'content_routes.dart';

@Component(
    selector: 'start-page',
    styleUrls: ['content_styles.css', 'start_page.css'],
    templateUrl: 'start_page.html',
    directives: <dynamic>[coreDirectives, routerDirectives, PostFeed],
    exports: [AboutRoutes, ContentRoutes])
class StartPage {}
