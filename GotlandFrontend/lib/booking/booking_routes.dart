import 'package:angular_router/angular_router.dart';

import '../app_routes.dart';

class BookingRoutes {
	static final RoutePath countdown = RoutePath(path: 'nedrakning', parent: AppRoutes.booking);
	static final RoutePath editBooking = RoutePath(path: '', parent: AppRoutes.booking);
}
