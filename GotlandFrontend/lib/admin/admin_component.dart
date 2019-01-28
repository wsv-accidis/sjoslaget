import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../client/client_factory.dart';
import 'admin_dashboard_page.template.dart';
import 'admin_login_page.template.dart';
import 'admin_routes.dart';

@Component(
	selector: 'gotland-admin-app',
	styleUrls: ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	providers: <dynamic>[
		ClientFactory
	],
	directives: <dynamic>[routerDirectives]
)
class AdminComponent {
	final List<RouteDefinition> routes = [
		RouteDefinition(routePath: AdminRoutes.dashboard, component: AdminDashboardPageNgFactory),
		RouteDefinition(routePath: AdminRoutes.login, component: AdminLoginPageNgFactory),
	];
}
