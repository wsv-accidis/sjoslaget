import 'dart:async';
import 'dart:html' show Event, HtmlElement, window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' as str show isNotEmpty;

import 'booking_component.dart';
import 'booking_validator.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css', 'booking_cabins_styles.css'],
	directives: const [materialDirectives, SpinnerWidget],
	providers: const [materialProviders]
)
class BookingCabinsPage implements OnInit {
	final BookingRepository _bookingRepository;
	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;

	Map<String, int> availability;
	List<BookingCabinView> bookingCabins = new List<BookingCabinView>();
	BookingDetails bookingDetails;
	String bookingRef;
	List<CruiseCabin> cruiseCabins;
	bool isSaving = false;

	bool get canFinish => !isEmpty && isSaved && isValid && !isSaving;

	bool get canSave => !isEmpty && isValid && !isSaving;

	bool get isEmpty => bookingCabins.isEmpty;

	bool get isLoaded => null != availability && null != cruiseCabins;

	bool get isSaved => str.isNotEmpty(bookingRef);

	bool get isValid => bookingCabins.every((b) => b.isValid);

	BookingCabinsPage(this._bookingRepository, this._bookingValidator, this._clientFactory, this._cruiseRepository, this._router);

	Future<Null> ngOnInit() async {
		if (!window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			_router.navigate(['/Content/Booking']);
			return;
		}

		bookingDetails = new BookingDetails.fromJson(window.sessionStorage[BookingComponent.BOOKING]);
		final client = await _clientFactory.getClient();
		cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
		availability = await _cruiseRepository.getAvailability(client);
	}

	void addCabin(String id) {
		final cabin = _getCruiseCabin(id);
		final bookingCabin = new BookingCabinView(cabin);
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

	String uniqueId(String prefix, int cabin, int pax) {
		final idx = (100 * cabin) + pax;
		return prefix + '_' + idx.toString();
	}

	Future<Null> saveBooking() async {
		isSaving = true;

		List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(bookingCabins);

		final client = await _clientFactory.getClient();
		await _bookingRepository.saveOrUpdateBooking(client, bookingDetails, cabinsToSave);

		isSaving = false;
	}

	void validate(Event event) {
		final bookingIdx = _findBookingIndex(event.target);
		if (bookingIdx >= 0 && bookingIdx < bookingCabins.length) {
			_bookingValidator.validateCabin(bookingCabins[bookingIdx]);
		}
	}

	int _findBookingIndex(HtmlElement target) {
		if (!target.dataset.containsKey('idx')) {
			return null == target.parent ? -1 : _findBookingIndex(target.parent);
		}
		return int.parse(target.dataset['idx']);
	}

	CruiseCabin _getCruiseCabin(id) {
		return cruiseCabins.firstWhere((c) => c.id == id);
	}
}
