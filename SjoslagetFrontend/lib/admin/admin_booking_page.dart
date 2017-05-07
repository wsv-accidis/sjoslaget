import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../booking/cabins_component.dart';
import '../client/availability_exception.dart';
import '../client/booking_exception.dart';
import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_result.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../model/payment_summary.dart';
import '../util/currency_formatter.dart';
import '../util/datetime_formatter.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'admin-booking-page',
	templateUrl: 'admin_booking_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_booking_page.css'],
	directives: const<dynamic>[materialDirectives, SpinnerWidget, CabinsComponent],
	providers: const<dynamic>[materialProviders]
)
class AdminBookingPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final RouteParams _routeParams;

	bool _isLockingUnlocking = false;

	@ViewChild('cabins')
	CabinsComponent cabins;

	BookingSource booking;
	String bookingError;
	bool isSaving = false;
	String payment;
	String paymentError;

	bool get canLock => null != booking && !booking.isLocked;

	bool get canUnlock => null != booking && booking.isLocked;

	bool get isLockingUnlocking => _isLockingUnlocking || isSaving;

	bool get canSaveCabins => !cabins.isEmpty && cabins.isValid && !isSaving;

	bool get hasBookingError => isNotEmpty(bookingError);

	bool get hasLoaded => null != booking;

	bool get hasPaymentError => isNotEmpty(paymentError);

	String get latestPaymentFormatted => null != booking && null != booking.payment ? DateTimeFormatter.format(booking.payment.latest) : '';

	AdminBookingPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._routeParams);

	Future<Null> lockUnlockBooking() async {
		if (!hasLoaded || isLockingUnlocking)
			return;

		_isLockingUnlocking = true;
		try {
			final client = await _clientFactory.getClient();
			final bool isLocked = await _bookingRepository.lockUnlockBooking(client, booking.reference);
			booking.isLocked = isLocked;
		} catch (e) {
			print('Failed to lock/unlock cruise: ' + e.toString());
		} finally {
			_isLockingUnlocking = false;
		}
	}

	Future<Null> ngOnInit() async {
		final String reference = _routeParams.get('ref');

		try {
			final client = await _clientFactory.getClient();
			booking = await _bookingRepository.findBooking(client, reference);

			final List<CruiseCabin> cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			cabins.amountPaid = booking.payment.total;
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.validateAll();

			_refreshRemainingPrice();
		} catch (e) {
			print('Failed to load booking: ' + e.toString());
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	Future<Null> registerPayment() async {
		if (isSaving)
			return;

		isSaving = true;

		try {
			Decimal paymentDec;
			try {
				paymentDec = Decimal.parse(payment.replaceAll(',', '.'));
			} catch (e) {
				print('Exception parsing payment amount: ' + e.toString());
				paymentError = 'Felaktigt belopp. Kontrollera att fältet bara innehåller siffror, eventuellt minustecken och decimalpunkt.';
				return;
			}

			try {
				final client = await _clientFactory.getClient();
				final PaymentSummary result = await _bookingRepository.registerPayment(client, booking.reference, paymentDec);

				cabins.amountPaid = result.total;
				booking.payment = result;

				_refreshRemainingPrice();
			} catch (e) {
				print('Failed to register payment: ' + e.toString());
				paymentError = 'Någonting gick fel när betalningen skulle registreras. Försök igen.';
			}
		} finally {
			isSaving = false;
		}
	}

	Future<Null> saveBooking() async {
		// This is very similar to saveBooking in booking_cabins_page, keep the two in sync

		if (isSaving)
			return;

		isSaving = true;
		cabins.disableAddCabins = true;
		bookingError = null;

		try {
			final List<BookingCabin> cabinsToSave = BookingCabinView.listToListOfBookingCabin(cabins.bookingCabins);
			final client = await _clientFactory.getClient();

			try {
				await _bookingRepository.saveOrUpdateBooking(client, booking, cabinsToSave);
			} catch (e) {
				if (e is AvailabilityException) {
					await cabins.refreshAvailability();
					List<BookingCabin> savedCabins = null;
					// Try to get the last saved booking, then we can compare the number of cabins to see where avail failed
					try {
						final BookingSource lastSavedBooking = await _bookingRepository.findBooking(client, booking.reference);
						savedCabins = lastSavedBooking.cabins;
					} catch (e) {
						print('Failed to retrieve prior booking for checking availability: ' + e.toString());
					}
					bookingError = _getAvailabilityError(savedCabins);
				}
				else if (e is BookingException) {
					// Exception from backend, validation error (should not happen as we validate locally, but oh well)
					bookingError = 'Någonting gick fel när bokningen skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen.';
				} else {
					// Exception which is not coming from backend, potentially bad network
					bookingError = 'Någonting gick fel när bokningen skulle sparas. Kontrollera att du är ansluten till internet och försök igen.';
				}
				print('Failed to save booking: ' + e.toString());
				return;
			}

			await cabins.refreshAvailability();
			cabins.onSaved();
		} finally {
			cabins.disableAddCabins = false;
			isSaving = false;
		}
	}

	String _getAvailabilityError(List<BookingCabin> savedCabins) {
		// Calling this depends on having refreshed availability first

		String error = 'Det finns inte tillräckligt många lediga hytter för att spara.';
		for (CruiseCabin cabin in cabins.cruiseCabins) {
			final int available = cabins.getTotalAvailability(cabin.id);
			final int inBooking = cabins.getNumberOfCabinsInBooking(cabin.id);
			final int inSavedBooking = _getNumberOfCabinsOfType(savedCabins, cabin.id);

			if (available < inBooking)
				error += ' Det finns $inBooking hytt(er) av typen ${cabin.name} i bokningen, men det finns ${available + inSavedBooking} kvar att boka.';
		}

		error += ' Ta bort hytter från bokningen eller byt till en annan typ och försök igen.';
		return error;
	}

	static int _getNumberOfCabinsOfType(List<BookingCabin> cabins, String id) {
		if (null == cabins)
			return 0;

		return cabins
			.where((b) => b.cabinTypeId == id)
			.length;
	}

	void _refreshRemainingPrice() {
		final remainingPrice = cabins.remainingPrice;
		if (remainingPrice.ceilToDouble() > 0.0) {
			payment = CurrencyFormatter.formatDecimalForInput(remainingPrice);
		}
	}
}
