import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'app_routes.dart';
import 'booking/booking_component.template.dart';
import 'booking/booking_validator.dart';
import 'client/booking_repository.dart';
import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'content/content_component.template.dart';

@Component(
	selector: 'sjoslaget-app',
	template: '''
	<router-outlet [routes]="routes"></router-outlet>
	''',
	providers: <dynamic>[
		BookingRepository,
		BookingValidator,
		ClientFactory,
		CruiseRepository,
		routerProviders
	],
	directives: <dynamic>[routerDirectives]
)
class AppComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AppRoutes.booking, component: BookingComponentNgFactory),
		RouteDefinition(routePath: AppRoutes.content, component: ContentComponentNgFactory)
	];
}
