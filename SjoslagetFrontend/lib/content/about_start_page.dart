import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'about_routes.dart';
import 'content_routes.dart';

@Component(
    selector: 'about-start-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'about_start_page_vk.html',
    directives: <dynamic>[routerDirectives, MaterialIconComponent],
    exports: [AboutRoutes, ContentRoutes])
class AboutStartPage {}
