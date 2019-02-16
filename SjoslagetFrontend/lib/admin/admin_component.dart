import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../booking/booking_validator.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../client/deleted_booking_repository.dart';
import '../client/printer_repository.dart';
import '../client/user_repository.dart';
import 'admin_booking_list_page.template.dart';
import 'admin_booking_page.template.dart';
import 'admin_dashboard_page.template.dart';
import 'admin_deleted_list_page.template.dart';
import 'admin_export_page.template.dart';
import 'admin_login_page.template.dart';
import 'admin_pax_list_page.template.dart';
import 'admin_routes.dart';
import 'admin_stats_page.template.dart';
import 'admin_user_page.template.dart';

@Component(
	selector: 'sjoslaget-admin-app',
	styleUrls: ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	providers: <dynamic>[
		BookingRepository,
		BookingValidator,
		ClientFactory,
		CruiseRepository,
		DeletedBookingRepository,
		PrinterRepository,
		UserRepository
	],
	directives: <dynamic>[routerDirectives]
)
class AdminComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AdminRoutes.dashboard, component: AdminDashboardPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.booking, component: AdminBookingPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.bookingList, component: AdminBookingListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.user, component: AdminUserPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.paxList, component: AdminPaxListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.export, component: AdminExportPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.login, component: AdminLoginPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.deletedList, component: AdminDeletedListPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.stats, component: AdminStatsPageNgFactory),
	];
}
