import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'admin/admin_component.dart';
import 'booking/booking_component.dart';
import 'booking/booking_validator.dart';
import 'content/content_component.dart';

import 'client/booking_repository.dart';
import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'client/session_storage_cache.dart';
import 'client/user_repository.dart';

@Component(
	selector: 'sjoslaget-app',
	template: '''
	<router-outlet></router-outlet>
	''',
	providers: const <dynamic>[BookingRepository, BookingValidator, ClientFactory, CruiseRepository, SessionStorageCache, UserRepository],
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/admin/...', name: 'Admin', component: AdminComponent),
	const Route(path: '/bokning/...', name: 'MyBooking', component: BookingComponent),
	const Route(path: '/...', name: 'Content', component: ContentComponent, useAsDefault: true)
])
class AppComponent {
}
