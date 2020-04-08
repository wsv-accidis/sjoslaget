import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'about_routes.dart';
import 'content_routes.dart';

@Component(
    selector: 'about-faq-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'about_faq_page_vk.html',
    directives: <dynamic>[routerDirectives],
    exports: [AboutRoutes, ContentRoutes])
class AboutFaqPage {}
