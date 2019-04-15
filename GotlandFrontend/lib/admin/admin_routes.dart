import 'package:angular_router/angular_router.dart';

class AdminRoutes {
	static final RoutePath dashboard = RoutePath(
		path: '',
		useAsDefault: true
	);
	static final RoutePath allocationList = RoutePath(path: 'boenden');
	static final RoutePath booking = RoutePath(path: 'bokning/:ref');
	static final RoutePath bookingList = RoutePath(path: 'bokningar');
	static final RoutePath externalBookingList = RoutePath(path: 'externa-bokningar');
	static final RoutePath login = RoutePath(path: 'login');
	static final RoutePath paxList = RoutePath(path: 'deltagare');
	static final RoutePath user = RoutePath(path: 'byt-losenord');

	static String bookingUrl(String ref) =>
		booking.toUrl(parameters: <String, String>{'ref': ref});
}
