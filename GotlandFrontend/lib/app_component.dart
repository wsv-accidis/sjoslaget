import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'app_routes.dart';
import 'booking/booking_component.template.dart';
import 'booking/booking_validator.dart';
import 'client/allocation_repository.dart';
import 'client/booking_repository.dart';
import 'client/client_factory.dart';
import 'client/event_repository.dart';
import 'client/payment_repository.dart';
import 'client/queue_repository.dart';
import 'content/content_component.template.dart';
import 'util/temp_credentials_store.dart';

@Component(
	selector: 'gotland-app',
	template: '''
	<router-outlet [routes]="routes"></router-outlet>
	''',
	providers: <dynamic>[
		AllocationRepository,
		BookingValidator,
		BookingRepository,
		ClientFactory,
		EventRepository,
		PaymentRepository,
		QueueRepository,
		TempCredentialsStore
	],
	directives: <dynamic>[routerDirectives]
)
class AppComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AppRoutes.booking, component: BookingComponentNgFactory),
		RouteDefinition(routePath: AppRoutes.content, component: ContentComponentNgFactory)
	];
}
