import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../booking/booking_validator.dart';
import '../client/allocation_repository.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../client/external_booking_repository.dart';
import '../client/payment_repository.dart';
import '../client/queue_admin_repository.dart';
import '../client/user_repository.dart';
import '../util/temp_credentials_store.dart';
import 'admin_alloc_list_page.template.dart';
import 'admin_booking_list_page.template.dart';
import 'admin_booking_page.template.dart';
import 'admin_dashboard_page.template.dart';
import 'admin_external_booking_list_page.template.dart';
import 'admin_login_page.template.dart';
import 'admin_pax_list_page.template.dart';
import 'admin_routes.dart';
import 'admin_user_page.template.dart';

@Component(
	selector: 'gotland-admin-app',
	styleUrls: ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	providers: <dynamic>[
		AllocationRepository,
		BookingRepository,
		BookingValidator,
		ClientFactory,
		EventRepository,
		ExternalBookingRepository,
		PaymentRepository,
		QueueAdminRepository,
		TempCredentialsStore,
		UserRepository
	],
	directives: <dynamic>[routerDirectives]
)
class AdminComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AdminRoutes.allocationList, component: AdminAllocListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.booking, component: AdminBookingPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.bookingList, component: AdminBookingListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.dashboard, component: AdminDashboardPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.externalBookingList, component: AdminExternalBookingListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.login, component: AdminLoginPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.paxList, component: AdminPaxListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.user, component: AdminUserPageNgFactory),
	];
}
