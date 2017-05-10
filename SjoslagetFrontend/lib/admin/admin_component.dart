import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import 'admin_booking_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_login_page.dart';
import 'admin_user_page.dart';
import '../client/client_factory.dart';

@Component(
	selector: 'admin-component',
	styleUrls: const ['../booking/booking_component.css'],
	templateUrl: '../booking/booking_component.html',
	directives: const<dynamic>[ROUTER_DIRECTIVES]
)
@RouteConfig(const [
	const Route(path: '/', name: 'Dashboard', component: AdminDashboardPage),
	const Route(path: '/bokning/:ref', name: 'Booking', component: AdminBookingPage),
	const Route(path: '/login', name: 'Login', component: AdminLoginPage),
	const Route(path: '/user', name: 'User', component: AdminUserPage)

])
class AdminComponent implements OnInit {
	final ClientFactory _clientFactory;
	final Router _router;

	AdminComponent(this._clientFactory, this._router);

	void ngOnInit() {
		/*
		 * This will not catch any navigation attempt into one of the admin pages, it's only here as a convenience.
		 *
		 * There is no point in trying to make this watertight as a savvy user can always fool the client side into
		 * thinking they are an admin, but they can't do anything since they lack the necessary access server side.
		 */
		if (!_clientFactory.isAdmin && !(_router.currentInstruction.component.componentType is AdminLoginPage)) {
			_router.navigate(<dynamic>['/Admin/Login']);
		}
	}
}
