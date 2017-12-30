import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content/content_component.dart';

@Component(
	selector: 'gotland-app',
	template: '''
	<router-outlet></router-outlet>
	''',
	providers: const <dynamic>[
	],
	directives: const <dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	//const Route(path: '/admin/...', name: 'Admin', component: AdminComponent),
	//const Route(path: '/bokning/...', name: 'MyBooking', component: BookingComponent),
	const Route(path: '/...', name: 'Content', component: ContentComponent, useAsDefault: true)
])
class AppComponent {
}
