import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'booking_edit_page.template.dart';
import 'booking_routes.dart';
import 'countdown_page.template.dart';

@Component(
	selector: 'booking-component',
	styleUrls: ['booking_component.css'],
	templateUrl: 'booking_component.html',
	directives: <dynamic>[routerDirectives],
)
class BookingComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: BookingRoutes.countdown, component: CountdownPageNgFactory),
		RouteDefinition(routePath: BookingRoutes.editBooking, component: BookingEditPageNgFactory)
	];
}
