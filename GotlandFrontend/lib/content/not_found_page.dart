import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

@Component(
	selector: 'not-found-page',
	styleUrls: ['content_styles.css'],
	templateUrl: 'not_found_page.html',
	directives: <dynamic>[routerDirectives],
	exports: [ContentRoutes]
)
class NotFoundPage {
}
