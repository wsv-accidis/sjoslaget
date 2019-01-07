import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'booking_page.template.dart';
import 'booking_routes.dart';

@Component(
	selector: 'booking-component',
	styleUrls: ['booking_component.css'],
	templateUrl: 'booking_component.html',
	directives: <dynamic>[routerDirectives],
)
class BookingComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: BookingRoutes.editBooking, component: BookingPageNgFactory)
	];
}
