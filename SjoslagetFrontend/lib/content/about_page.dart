import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

@Component(
    selector: 'about-start-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'about_page.html',
    directives: <dynamic>[routerDirectives, MaterialIconComponent],
    exports: [ContentRoutes])
class AboutPage {}
