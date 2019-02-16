import 'package:angular_router/angular_router.dart';

class AdminRoutes {
	static final RoutePath dashboard = RoutePath(
		path: '',
		useAsDefault: true
	);
	static final RoutePath bookingList = RoutePath(path: 'bokningar');
	static final RoutePath login = RoutePath(path: 'login');
	static final RoutePath paxList = RoutePath(path: 'deltagare');
}
