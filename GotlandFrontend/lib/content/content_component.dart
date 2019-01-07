import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';
import 'countdown_page.template.dart';
import 'start_page.template.dart';

@Component(
	selector: 'content-component',
	styleUrls: ['content_component.css'],
	templateUrl: 'content_component.html',
	directives: <dynamic>[routerDirectives],
)
class ContentComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: ContentRoutes.start, component: StartPageNgFactory),
		RouteDefinition(routePath: ContentRoutes.countdown, component: CountdownPageNgFactory),
		//RouteDefinition(path: '.+', component: NotFoundPageNgFactory),
	];
}
