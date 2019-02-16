import 'dart:async';
import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model.dart';
import 'package:quiver/strings.dart' show equalsIgnoreCase, isEmpty, isNotEmpty;

import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../content/about_routes.dart';
import '../content/content_routes.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_details.dart';
import '../model/booking_source.dart';
import '../model/cruise.dart';
import '../model/cruise_cabin.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'booking_component.dart';
import 'booking_support_utils.dart';
import 'cabins_component.dart';
import 'products_component.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: ['../content/content_styles.css', 'booking_cabins_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, CabinsComponent, ProductsComponent, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AboutRoutes]
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

	BookingCabinsPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._router);

	bool get canFinish => !cabins.isEmpty && isSaved && cabins.isValid && products.isValid && !isSaving;

	bool get canSave => !cabins.isEmpty && cabins.isValid && products.isValid && !isSaving;

	bool get hasBookingError => isNotEmpty(bookingError);

	bool get hasLoadingError => isNotEmpty(loadingError);

	bool get hasLoaded => null != bookingDetails;

	bool get isExisting => isSaved && isEmpty(bookingResult.password);

	bool get isNewlySaved => isSaved && isNotEmpty(bookingResult.password);

	bool get isSaved => null != bookingResult;

	@override
	Future<Null> ngOnInit() async {
		if (window.sessionStorage.containsKey(BookingComponent.BOOKING)) {
			/*
			 * Initialize a new booking where the previously supplied details are in session storage.
			 */
			bookingDetails = BookingDetails.fromJson(window.sessionStorage[BookingComponent.BOOKING]);
			cabins.registerAddonProvider(products);
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
				booking = await _bookingRepository.getBooking(client, reference);
			} catch (e) {
				print('Failed to get cabins or booking due to an exception: ${e.toString()}');
				loadingError = 'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen. Om felet kvarstår, kontakta oss.';
				cabins.disableAddCabins = true;
				return;
			}

			bookingResult = BookingResult(reference, null);
			bookingDetails = booking;

			cabins.amountPaid = booking.payment.total;
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.discountPercent = booking.discount;
			cabins.readOnly = booking.isLocked || cruise.isLocked;

			products.quantitiesFromBooking = booking.products;
			products.readOnly = cabins.readOnly;
			cabins.registerAddonProvider(products);

			if (!cabins.readOnly)
				cabins.validateAll();

			isNewBooking = false;
		} else {
			/*
			 * Failure case, navigate out of here. User is an admin, or has no booking.
			 * TODO Handle the case where an admin tries to create a booking through the normal user interface.
			 */
			await _router.navigateByUrl(ContentRoutes.booking.toUrl());
		}
	}

	void finishBooking() {
		_clientFactory.clear();
		window.sessionStorage.remove(BookingComponent.BOOKING);
		_router.navigateByUrl(ContentRoutes.booking.toUrl());
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
			final tuple = await BookingSupportUtils.saveBooking(
				_clientFactory,
				_bookingRepository,
				bookingDetails,
				cabins,
				products,
				bookingResult,
			);

			// item1 is BookingResult
			// item2 is String (bookingError)
			final BookingResult result = tuple.item1;
			if (null == result) {
				bookingError = tuple.item2;
				return;
			}

			// Ensure that if we save again the currently displayed password is not lost
			if (null != bookingResult && isNotEmpty(bookingResult.password) && isEmpty(result.password))
				result.password = bookingResult.password;

			bookingResult = result;
			bookingDetails.reference = result.reference;

			await cabins.refreshAvailability();
			await products.refreshAvailability();
			cabins.onSaved();

			if (!equalsIgnoreCase(_clientFactory.authenticatedUser, bookingResult.reference) && isNotEmpty(bookingResult.password)) {
				try {
					await _clientFactory.authenticate(bookingResult.reference, bookingResult.password);
				} catch (e) {
					// If we are here then saving succeeded but then logging in failed for some reason. Odd.
					// Force-finish the booking so we don't end up in an unknown state.
					print('Authentication failed after booking was successfully saved: ${e.toString()}');
					finishBooking();
				}
			}
		} finally {
			cabins.disableAddCabins = false;
			isSaving = false;
		}
	}
}
