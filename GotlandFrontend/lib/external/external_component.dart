import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../client/client_factory.dart';
import '../client/external_booking_repository.dart';
import 'external_booking_page.template.dart';
import 'external_routes.dart';

@Component(
	selector: 'gotland-external-app',
	styleUrls: ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	providers: <dynamic>[ClientFactory, ExternalBookingRepository],
	directives: <dynamic>[routerDirectives]
)
class ExternalComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: ExternalRoutes.createBooking, component: ExternalBookingPageNgFactory)
	];
}
