import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:quiver/strings.dart' show equalsIgnoreCase, isEmpty, isNotEmpty;

import 'booking_component.dart';
import 'cabins_component.dart';
import 'products_component.dart';
import '../client/availability_exception.dart';
import '../client/booking_exception.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/booking_product.dart';
import '../model/booking_product_view.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';
import '../model/cruise.dart';
import '../model/cruise_cabin.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css', 'booking_cabins_styles.css'],
	directives: const <dynamic>[materialDirectives, SpinnerWidget, CabinsComponent, ProductsComponent],
	providers: const <dynamic>[materialProviders]
)
class BookingCabinsPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;

	@ViewChild('cabins')
	CabinsComponent cabins;

	@ViewChild('products')
	ProductsComponent products;

	BookingDetails bookingDetails;
	String bookingError;
	BookingResult bookingResult;
	bool isSaving = false;
	String loadingError;
	bool isNewBooking;

	bool get canFinish => !cabins.isEmpty && isSaved && cabins.isValid && products.isValid && !isSaving;

	bool get canSave => !cabins.isEmpty && cabins.isValid && products.isValid && !isSaving;

	bool get hasBookingError => isNotEmpty(bookingError);

	bool get hasLoadingError => isNotEmpty(loadingError);

	bool get hasLoaded => null != bookingDetails;

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
			isNewBooking = true;
		} else if (_clientFactory.hasCredentials && !_clientFactory.isAdmin) {
			/*
			 * Initialize from an existing booking which we have already authenticated for.
			 */
			final String reference = _clientFactory.authenticatedUser;
			List<CruiseCabin> cruiseCabins;
			BookingSource booking;
			Cruise cruise;

			try {
				final client = _clientFactory.getClient();
				cruise = await _cruiseRepository.getActiveCruise(client);
				cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
				booking = await _bookingRepository.findBooking(client, reference);
			} catch (e) {
				print('Failed to get cabins or booking due to an exception: ' + e.toString());
				loadingError = 'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen. Om felet kvarstår, kontakta Sjöslaget.';
				cabins.disableAddCabins = true;
				return;
			}

			bookingResult = new BookingResult(reference, null);
			bookingDetails = booking;

			cabins.amountPaid = booking.payment.total;
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.discountPercent = booking.discount;
			cabins.readOnly = booking.isLocked || cruise.isLocked;

			products.quantitiesFromBooking = booking.products;
			cabins.registerAddonProvider(products);

			if (!cabins.readOnly)
				cabins.validateAll();

			isNewBooking = false;
		} else {
			/*
			 * Failure case, navigate out of here. User is an admin, or has no booking.
			 * TODO Handle the case where an admin tries to create a booking through the normal user interface.
			 */
			_router.navigate(<dynamic>['/Content/Booking']);
		}
	}

	void finishBooking() {
		_clientFactory.clear();
		window.sessionStorage.remove(BookingComponent.BOOKING);
		_router.navigate(<dynamic>['/Content/Booking']);
	}

	Future<Null> saveBooking() async {
		// This is very similar to saveBooking in admin_booking_page, keep the two in sync

		if (isSaving)
			return;

		isSaving = true;
		cabins.disableAddCabins = true;
		bookingError = null;
		window.sessionStorage.remove(BookingComponent.BOOKING);

		try {
			final List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(cabins.bookingCabins);
			final List<BookingProduct> productsToSave = BookingProductView.listToListOfBookingProduct(products.bookingProducts);
			final client = _clientFactory.getClient();
			BookingResult result;

			try {
				result = await _bookingRepository.saveOrUpdateBooking(client, bookingDetails, cabinsToSave, productsToSave);
			} catch (e) {
				if (e is AvailabilityException) {
					await cabins.refreshAvailability();
					List<BookingCabin> savedCabins = null;
					if (isSaved) {
						// Try to get the last saved booking, then we can compare the number of cabins to see where avail failed
						try {
							final BookingSource lastSavedBooking = await _bookingRepository.findBooking(client, bookingResult.reference);
							savedCabins = lastSavedBooking.cabins;
						} catch (e) {
							print('Failed to retrieve prior booking for checking availability: ' + e.toString());
						}
					}
					bookingError = _getAvailabilityError(savedCabins);
				}
				else if (e is BookingException) {
					// Exception from backend, validation error (should not happen as we validate locally, but oh well)
					bookingError = 'Någonting gick fel när din bokning skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen. Om problemet kvarstår, kontakta Sjöslaget.';
				} else {
					// Exception which is not coming from backend, potentially bad network
					bookingError = 'Någonting gick fel när din bokning skulle sparas. Kontrollera att du är ansluten till internet och försök igen. Om problemet kvarstår, kontakta Sjöslaget.';
				}
				print('Failed to save booking: ' + e.toString());
				return;
			}

			// Ensure that if we save again the currently displayed password is not lost
			if (null != bookingResult && isNotEmpty(bookingResult.password) && isEmpty(result.password))
				result.password = bookingResult.password;

			bookingResult = result;
			bookingDetails.reference = result.reference;

			await cabins.refreshAvailability();
			cabins.onSaved();

			if (!equalsIgnoreCase(_clientFactory.authenticatedUser, bookingResult.reference) && isNotEmpty(bookingResult.password)) {
				try {
					await _clientFactory.authenticate(bookingResult.reference, bookingResult.password);
				} catch (e) {
					// If we are here then saving succeeded but then logging in failed for some reason. Odd.
					// Force-finish the booking so we don't end up in an unknown state.
					print('Authentication failed after booking was successfully saved: ' + e.toString());
					finishBooking();
				}
			}
		} finally {
			cabins.disableAddCabins = false;
			isSaving = false;
		}
	}

	String _getAvailabilityError(List<BookingCabin> savedCabins) {
		// Calling this depends on having refreshed availability first

		String error = 'Det finns inte tillräckligt många lediga hytter för att spara din bokning.';
		for (CruiseCabin cabin in cabins.cruiseCabins) {
			final int available = cabins.getTotalAvailability(cabin.id);
			final int inBooking = cabins.getNumberOfCabinsInBooking(cabin.id);
			final int inSavedBooking = _getNumberOfCabinsOfType(savedCabins, cabin.id);

			if (available < inBooking)
				error += ' Du har $inBooking hytt(er) av typen ${cabin.name} i din bokning, men det finns ${available + inSavedBooking} kvar att boka.';
		}

		error += ' Ta bort hytter från din bokning eller byt till en annan typ och försök igen.';
		if (isSaved)
			error += ' Du har fortfarande kvar alla hytter som ingick i din senast sparade bokning.';

		return error;
	}

	static int _getNumberOfCabinsOfType(List<BookingCabin> cabins, String id) {
		if (null == cabins)
			return 0;

		return cabins
			.where((b) => b.cabinTypeId == id)
			.length;
	}
}
