import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import '../booking/booking_details_component.dart';
import '../booking/booking_login_component.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: const [BookingDetailsComponent, BookingLoginComponent, ROUTER_DIRECTIVES]
)
class BookingPage {
}
