import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:quiver/strings.dart' as str show isNotEmpty;

import '../booking/booking_component.dart';
import '../booking/booking_details_component.dart';
import '../booking/booking_login_component.dart';
import '../model/booking_details.dart';

@Component(
	selector: 'booking-page',
	styleUrls: const ['content_styles.css'],
	templateUrl: 'booking_page.html',
	directives: const [BookingDetailsComponent, BookingLoginComponent, ROUTER_DIRECTIVES]
)
class BookingPage implements OnInit {
	final Router _router;

	@ViewChild('bookingDetails')
	BookingDetailsComponent bookingDetails;

	bool forceOpenBooking;

	BookingPage(this._router);

	Future<Null> ngOnInit() async {
		forceOpenBooking = str.isNotEmpty(window.sessionStorage['forceOpenBooking']);
		bookingDetails.setOnSubmitListener(onSubmitBooking);
	}

	void onSubmitBooking(BookingDetailsComponent details) {
		final bookingDetails = new BookingDetails(
			details.firstName,
			details.lastName,
			details.phoneNo,
			details.email,
			details.lunch
		);

		window.sessionStorage[BookingComponent.BOOKING] = bookingDetails.toJson();
		_router.navigate(['/MyBooking/EditCabins']);
	}
}
