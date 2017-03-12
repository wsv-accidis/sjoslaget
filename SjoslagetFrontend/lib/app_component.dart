import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'booking/booking_component.dart';
import 'content/content_component.dart';

import 'client/client_factory.dart';
import 'client/cruise_repository.dart';
import 'client/session_storage_cache.dart';

@Component(
	selector: 'sjoslaget-app',
	template: '''
	<router-outlet></router-outlet>
	''',
	providers: const [ClientFactory, CruiseRepository, SessionStorageCache],
	directives: const [ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/bokning/...', name: 'MyBooking', component: BookingComponent),
	const Route(path: '/...', name: 'Content', component: ContentComponent, useAsDefault: true)
])
class AppComponent {
}
