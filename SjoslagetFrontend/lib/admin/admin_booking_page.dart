import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';

import '../booking/cabins_component.dart';
import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-booking-page',
	templateUrl: 'admin_booking_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_dashboard_page.css'],
	directives: const<dynamic>[materialDirectives, SpinnerWidget, CabinsComponent],
	providers: const<dynamic>[materialProviders]
)
class AdminBookingPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final RouteParams _routeParams;

	@ViewChild('cabins')
	CabinsComponent cabins;

	BookingSource booking;

	bool get canSave => false;

	bool get hasLoaded => null != booking;

	AdminBookingPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._routeParams);

	Future<Null> ngOnInit() async {
		final String reference = _routeParams.get('ref');

		try {
			final client = await _clientFactory.getClient();
			booking = await _bookingRepository.findBooking(client, reference);

			final List<CruiseCabin> cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.validateAll();
		} catch (e) {
			print('Failed to load booking: ' + e);
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}
}
