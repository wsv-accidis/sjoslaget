import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' show equalsIgnoreCase, isEmpty, isNotEmpty;

import 'booking_component.dart';
import 'cabins_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css', 'booking_cabins_styles.css'],
	directives: const [materialDirectives, SpinnerWidget, CabinsComponent],
	providers: const [materialProviders]
)
class BookingCabinsPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;

	@ViewChild('cabins')
	CabinsComponent cabins;

	BookingDetails bookingDetails;
	BookingResult bookingResult;

	bool isSaving = false;

	bool get canFinish => !cabins.isEmpty && isSaved && cabins.isValid && !isSaving;

	bool get canSave => !cabins.isEmpty && cabins.isValid && !isSaving;

	bool get isExisting => isSaved && isEmpty(bookingResult.password);

	bool get isNewlySaved => isSaved && isNotEmpty(bookingResult.password);

	bool get isSaved => null != bookingResult;

	BookingCabinsPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._router);

	Future<Null> ngOnInit() async {
		if (window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			/*
			 * Initialize a new booking where the previously supplied details are in session storage.
			 */
			bookingDetails = new BookingDetails.fromJson(window.sessionStorage[BookingComponent.BOOKING]);
		} else if (_clientFactory.hasCredentials && !_clientFactory.isAdmin) {
			/*
			 * Initialize from an existing booking which we have already authenticated for.
			 */
			final String reference = _clientFactory.authenticatedUser;
			final client = await _clientFactory.getClient();
			final List<CruiseCabin> cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			final BookingSource booking = await _bookingRepository.findBooking(client, reference);

			bookingResult = new BookingResult(reference, null);
			bookingDetails = booking;
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.validateAll();
		} else {
			/*
			 * Failure case, navigate out of here. User is an admin, or has no booking.
			 * TODO Handle the case where an admin tries to create a booking through the normal user interface.
			 */
			_router.navigate(['/Content/Booking']);
		}
	}

	void finishBooking() {
		_clientFactory.clear();
		window.sessionStorage.remove(BookingComponent.BOOKING);
		_router.navigate(['/Content/Booking']);
	}

	Future<Null> saveBooking() async {
		isSaving = true;

		final List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(cabins.bookingCabins);

		final client = await _clientFactory.getClient();
		bookingResult = await _bookingRepository.saveOrUpdateBooking(client, bookingDetails, cabinsToSave);
		bookingDetails.reference = bookingResult.reference;

		if (!equalsIgnoreCase(_clientFactory.authenticatedUser, bookingResult.reference) && isNotEmpty(bookingResult.password))
			await _clientFactory.authenticate(bookingResult.reference, bookingResult.password);

		isSaving = false;

		// TODO Error handling
	}
}
