import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'about_routes.dart';
import 'content_routes.dart';

@Component(
    selector: 'about-privacy-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'about_privacy_page.html',
    directives: <dynamic>[routerDirectives],
    exports: [AboutRoutes, ContentRoutes])
class AboutPrivacyPage {}
