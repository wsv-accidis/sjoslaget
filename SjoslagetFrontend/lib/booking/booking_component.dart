import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'booking_cabins_page.dart';

@Component(
	selector: 'booking-component',
	styleUrls: const ['booking_component.css'],
	templateUrl: 'booking_component.html',
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/hytter', name: 'EditCabins', component: BookingCabinsPage)
])
class BookingComponent {
	static const BOOKING = 'booking';
}
