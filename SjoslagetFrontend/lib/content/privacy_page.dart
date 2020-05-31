import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

@Component(
    selector: 'privacy-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'privacy_page.html',
    directives: <dynamic>[routerDirectives],
    exports: [ContentRoutes])
class PrivacyPage {}
