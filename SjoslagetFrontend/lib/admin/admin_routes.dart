import 'package:angular_router/angular_router.dart';

class AdminRoutes {
	static final RoutePath dashboard = RoutePath(
		path: '',
		useAsDefault: true
	);
	static final RoutePath booking = RoutePath(path: 'bokning/:ref');
	static final RoutePath bookingList = RoutePath(path: 'bokningar');
	static final RoutePath user = RoutePath(path: 'byt-losenord');
	static final RoutePath paxList = RoutePath(path: 'deltagare');
	static final RoutePath export = RoutePath(path: 'exportera');
	static final RoutePath login = RoutePath(path: 'login');
	static final RoutePath deletedList = RoutePath(path: 'papperskorg');
	static final RoutePath stats = RoutePath(path: 'rapport');

	static String bookingUrl(String ref) =>
		booking.toUrl(parameters: <String, String>{'ref': ref});
}
