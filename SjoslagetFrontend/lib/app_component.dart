import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'booking/booking_component.dart';
import 'booking/booking_validator.dart';
import 'client/booking_repository.dart';
import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'content/content_component.dart';

@Component(
	selector: 'sjoslaget-app',
	template: '''
	<router-outlet></router-outlet>
	''',
	providers: const <dynamic>[
		BookingRepository,
		BookingValidator,
		ClientFactory,
		CruiseRepository
	],
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/bokning/...', name: 'MyBooking', component: BookingComponent),
	const Route(path: '/...', name: 'Content', component: ContentComponent, useAsDefault: true)
])
class AppComponent {
}
