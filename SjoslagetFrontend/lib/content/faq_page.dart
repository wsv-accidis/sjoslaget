import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

@Component(
    selector: 'faq-page', styleUrls: ['content_styles.css'], templateUrl: 'faq_page_sj.html', directives: <dynamic>[routerDirectives], exports: [ContentRoutes])
class FaqPage {}
