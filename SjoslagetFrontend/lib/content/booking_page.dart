import 'package:angular2/core.dart';

import '../booking/booking_login_component.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: const [BookingLoginComponent]
)
class BookingPage {
}
