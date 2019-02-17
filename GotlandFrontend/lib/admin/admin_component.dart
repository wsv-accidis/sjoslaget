import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/queue_admin_repository.dart';
import '../client/user_repository.dart';
import 'admin_booking_list_page.template.dart';
import 'admin_dashboard_page.template.dart';
import 'admin_login_page.template.dart';
import 'admin_pax_list_page.template.dart';
import 'admin_user_page.template.dart';
import 'admin_routes.dart';

@Component(
	selector: 'gotland-admin-app',
	styleUrls: ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	providers: <dynamic>[
		BookingRepository,
		ClientFactory,
		EventRepository,
		QueueAdminRepository,
		UserRepository
	],
	directives: <dynamic>[routerDirectives]
)
class AdminComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AdminRoutes.bookingList, component: AdminBookingListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.dashboard, component: AdminDashboardPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.login, component: AdminLoginPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.paxList, component: AdminPaxListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.user, component: AdminUserPageNgFactory),
	];
}
