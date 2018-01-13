import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'booking/booking_component.dart';
import 'client/client_factory.dart';
import 'client/event_repository.dart';
import 'client/queue_repository.dart';
import 'content/content_component.dart';

@Component(
	selector: 'gotland-app',
	template: '''
	<router-outlet></router-outlet>
	''',
	providers: const <dynamic>[
		ClientFactory,
		EventRepository,
		QueueRepository
	],
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	//const Route(path: '/admin/...', name: 'Admin', component: AdminComponent),
	const Route(path: '/bokning/...', name: 'Booking', component: BookingComponent),
	const Route(path: '/...', name: 'Content', component: ContentComponent, useAsDefault: true)
])
class AppComponent {
}
