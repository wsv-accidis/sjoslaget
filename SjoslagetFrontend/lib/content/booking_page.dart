import 'dart:async';
import 'dart:convert';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

import '../booking/booking_component.dart';
import '../booking/booking_details_component.dart';
import '../booking/booking_login_component.dart';

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

	BookingPage(this._router);

	Future<Null> ngOnInit() async {
		bookingDetails.setOnSubmitListener(onSubmitBooking);
	}

	void onSubmitBooking(BookingDetailsComponent details) {
		window.sessionStorage[BookingComponent.BOOKING] = JSON.encode({
			BookingComponent.FIRSTNAME: details.firstName,
			BookingComponent.LASTNAME: details.lastName,
			BookingComponent.PHONE_NO: details.phoneNo,
			BookingComponent.EMAIL: details.email,
			BookingComponent.LUNCH: details.lunch,
		});

		_router.navigate(['../../MyBooking/EditCabins']);
	}
}
