import 'dart:async';
import 'dart:convert';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'booking_component.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin.dart';
import '../model/cruise_dabin.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css'],
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class BookingCabinsPage implements OnInit {
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	String firstName;
	List<BookingCabin> bookingCabins = new List<BookingCabin>();
	List<CruiseCabin> cabins;

	BookingCabinsPage(this._clientFactory, this._cruiseRepository);

	Future<Null> ngOnInit() async {
		if (!window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			return;
		}

		final client = await _clientFactory.getClient();
		cabins = await _cruiseRepository.getActiveCruiseCabins(client);

		Map<String, String> booking = JSON.decode(window.sessionStorage[BookingComponent.BOOKING]);
		firstName = booking[BookingComponent.FIRSTNAME];
	}

	void addCabin(String id) {
		final cabin = cabins.firstWhere((c) => c.id == id);
		final bookingCabin = new BookingCabin();
		bookingCabin.cabinTypeId = cabin.id;
		bookingCabins.add(bookingCabin);
	}
}
