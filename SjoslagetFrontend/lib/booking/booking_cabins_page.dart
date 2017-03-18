import 'dart:async';
import 'dart:convert';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'booking_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/cruise_cabin.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css', 'booking_cabins_styles.css'],
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class BookingCabinsPage implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	Map<String, int> availability;
	String firstName;
	List<BookingCabinView> bookingCabins = new List<BookingCabinView>();
	List<CruiseCabin> cruiseCabins;

	bool get isLoaded => null != availability && null != cruiseCabins;

	bool get isSaved => false;

	BookingCabinsPage(this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		if (!window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			return;
		}

		final client = await _clientFactory.getClient();
		cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
		availability = await _cruiseRepository.getAvailability(client);

		Map<String, String> booking = JSON.decode(window.sessionStorage[BookingComponent.BOOKING]);
		firstName = booking[BookingComponent.FIRSTNAME];
	}

	void addCabin(String id) {
		final cabin = getCruiseCabin(id);
		final bookingCabin = new BookingCabinView(cabin);
		bookingCabins.add(bookingCabin);
	}

	void deleteCabin(int idx) {
		bookingCabins.removeAt(idx);
	}

	CruiseCabin getCruiseCabin(id) {
		return cruiseCabins.firstWhere((c) => c.id == id);
	}

	int getAvailability(String id) {
		if (null == availability) {
			return 0;
		}

		final int inBooking = bookingCabins
			.where((b) => b.id == id)
			.length;
		if (!availability.containsKey(id))
			return 0;

		return availability[id] - inBooking;
	}

	bool hasAvailability(String id) {
		return getAvailability(id) > 0;
	}
}
