import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

@Component(
	selector: 'about-booking-page',
	styleUrls: ['content_styles.css'],
	templateUrl: 'about_booking_page_vk.html',
	directives: <dynamic>[routerDirectives],
	exports: [ContentRoutes]
)
class AboutBookingPage {
}
