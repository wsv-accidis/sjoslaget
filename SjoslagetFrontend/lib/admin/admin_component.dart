import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'admin_booking_page.dart';
import 'admin_booking_list_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_deleted_list_page.dart';
import 'admin_export_page.dart';
import 'admin_login_page.dart';
import 'admin_pax_list_page.dart';
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
	const Route(path: '/bokningar', name: 'BookingList', component: AdminBookingListPage),
	const Route(path: '/deltagare', name: 'PaxList', component: AdminPaxListPage),
	const Route(path: '/papperskorg', name: 'DeletedList', component: AdminDeletedListPage),
	const Route(path: '/exportera', name: 'Export', component: AdminExportPage),
	const Route(path: '/login', name: 'Login', component: AdminLoginPage),
	const Route(path: '/byt-losenord', name: 'User', component: AdminUserPage)

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
