import 'dart:async';
import 'dart:html' show Event, HtmlElement;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'booking_validator.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'cabins-component',
	templateUrl: 'cabins_component.html',
	styleUrls: const ['../content/content_styles.css', 'cabins_component.css'],
	directives: const [materialDirectives, SpinnerWidget],
	providers: const [materialProviders]
)
class CabinsComponent implements OnInit {
	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	Map<String, int> availability;
	List<BookingCabinView> bookingCabins = new List<BookingCabinView>();
	List<CruiseCabin> cruiseCabins;

	bool get isEmpty => bookingCabins.isEmpty;

	bool get isLoaded => null != availability && null != cruiseCabins;

	bool get isValid => bookingCabins.every((b) => b.isValid);

	CabinsComponent(this._bookingValidator, this._clientFactory, this._cruiseRepository);

	void addCabin(String id) {
		final cabin = _getCruiseCabin(id);
		final bookingCabin = new BookingCabinView.fromCruiseCabin(cabin);
		if (bookingCabins.isEmpty) {
			// First pax of the booking must have group set so it can be used as the default for everyone else
			bookingCabin.pax[0].firstRow = true;
		}

		bookingCabins.add(bookingCabin);
		_bookingValidator.validateCabin(bookingCabin);
	}

	void deleteCabin(int idx) {
		bookingCabins.removeAt(idx);

		if (0 == idx && bookingCabins.isNotEmpty) {
			// Reapply the firstRow flag to the new first row if the old one was removed
			final firstCabin = bookingCabins[0];
			firstCabin.pax[0].firstRow = true;
			_bookingValidator.validateCabin(firstCabin);
		}
	}

	int getAvailability(String id) {
		final int available = getTotalAvailability(id);
		final int inBooking = getNumberOfCabinsInBooking(id);
		return _max(0, available - inBooking);
	}

	int getNumberOfCabinsInBooking(String id) {
		return bookingCabins
			.where((b) => b.id == id)
			.length;
	}

	int getTotalAvailability(String id) {
		if (null == availability || !availability.containsKey(id))
			return 0;
		return availability[id];
	}

	bool hasAvailability(String id) {
		return getAvailability(id) > 0;
	}

	Future<Null> ngOnInit() async {
		final client = await _clientFactory.getClient();
		cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
		availability = await _cruiseRepository.getAvailability(client);
	}

	Future<Null> refreshAvailability() async {
		final client = await _clientFactory.getClient();
		availability = await _cruiseRepository.getAvailability(client);
	}

	String uniqueId(String prefix, int cabin, int pax) {
		final idx = (100 * cabin) + pax;
		return prefix + '_' + idx.toString();
	}

	void validate(Event event) {
		final bookingIdx = _findBookingIndex(event.target);
		if (bookingIdx >= 0 && bookingIdx < bookingCabins.length) {
			_bookingValidator.validateCabin(bookingCabins[bookingIdx]);
		}
	}

	void validateAll() {
		bookingCabins.forEach((b) => _bookingValidator.validateCabin(b));
	}

	int _findBookingIndex(HtmlElement target) {
		if (!target.dataset.containsKey('idx')) {
			return null == target.parent ? -1 : _findBookingIndex(target.parent);
		}
		return int.parse(target.dataset['idx']);
	}

	CruiseCabin _getCruiseCabin(String id) {
		return cruiseCabins.firstWhere((c) => c.id == id);
	}

	static int _max(int a, int b) {
		return a > b ? a : b;
	}
}
