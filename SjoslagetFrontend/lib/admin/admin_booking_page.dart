import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend_shared/model.dart' show BookingResult;
import 'package:frontend_shared/util.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../booking/booking_support_utils.dart';
import '../booking/cabins_component.dart';
import '../booking/products_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../client/user_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../model/payment_summary.dart';
import '../widgets/components.dart';
import '../widgets/modal_dialog.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';

@Component(
	selector: 'admin-booking-page',
	templateUrl: 'admin_booking_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, sjoslagetMaterialDirectives, CabinsComponent, ModalDialog, ProductsComponent, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes]
)
class AdminBookingPage implements OnActivate {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;
	final Router _router;
	final UserRepository _userRepository;

	bool _isLockingUnlocking = false;

	@ViewChild('cabins')
	CabinsComponent cabins;

	@ViewChild('deleteBookingDialog')
	ModalDialog deleteBookingDialog;

	@ViewChild('products')
	ProductsComponent products;

	BookingSource booking;
	String bookingError;
	String discount;
	bool isSaving = false;
	String newPinCode;
	String payment;
	String paymentError;
	String resetPinCodeError;

	AdminBookingPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._router, this._userRepository);

	bool get canDelete => !isSaving;

	bool get canLock => null != booking && !booking.isLocked;

	bool get canUnlock => null != booking && booking.isLocked;

	bool get isLockingUnlocking => _isLockingUnlocking || isSaving;

	bool get canSave => !cabins.isEmpty && cabins.isValid && products.isValid && !isSaving;

	bool get hasBookingError => isNotEmpty(bookingError);

	bool get hasLoaded => null != booking;

	bool get hasPaymentError => isNotEmpty(paymentError);

	bool get hasResetPinCode => isNotEmpty(newPinCode);

	bool get hasResetPinCodeError => isNotEmpty(resetPinCodeError);

	String get latestPaymentFormatted => null != booking && null != booking.payment ? DateTimeFormatter.format(booking.payment.latest) : '';

	Future<Null> deleteBooking() async {
		if (isSaving)
			return;
		if (!await deleteBookingDialog.openAsync())
			return;

		isSaving = true;

		try {
			final client = _clientFactory.getClient();
			await _bookingRepository.deleteBooking(client, booking.reference);
		} catch (e) {
			print('Failed to delete booking: ${e.toString()}');
		} finally {
			isSaving = false;
		}

		await _router.navigateByUrl(AdminRoutes.dashboard.toUrl());
	}

	Future<Null> lockUnlockBooking() async {
		if (!hasLoaded || isLockingUnlocking)
			return;

		_isLockingUnlocking = true;
		try {
			final client = _clientFactory.getClient();
			final bool isLocked = await _bookingRepository.lockUnlockBooking(client, booking.reference);
			booking.isLocked = isLocked;
		} catch (e) {
			print('Failed to lock/unlock booking: ${e.toString()}');
		} finally {
			_isLockingUnlocking = false;
		}
	}

	@override
	void onActivate(_, RouterState routerState) async {
		final String reference = routerState.parameters['ref'];

		try {
			final client = _clientFactory.getClient();
			booking = await _bookingRepository.findBooking(client, reference);

			final List<CruiseCabin> cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			cabins.amountPaid = booking.payment.total;
			cabins.bookingCabins = BookingCabinView.listOfBookingCabinToList(booking.cabins, cruiseCabins);
			cabins.discountPercent = booking.discount;

			products.showProductNote = false;
			products.quantitiesFromBooking = booking.products;
			cabins.registerAddonProvider(products);

			cabins.validateAll();

			_refreshPayment();
		} catch (e) {
			print('Failed to load booking: ${e.toString()}');
			// Just ignore this here, we will be stuck in the loading state until the user refreshes
		}
	}

	Future<Null> registerPayment() async {
		if (isSaving)
			return;

		isSaving = true;
		paymentError = null;

		try {
			Decimal paymentDec;
			try {
				paymentDec = Decimal.parse(payment.replaceAll(',', '.'));
			} catch (e) {
				print('Exception parsing payment amount: ${e.toString()}');
				paymentError = 'Felaktigt belopp. Kontrollera att fältet bara innehåller siffror, eventuellt minustecken och decimalpunkt.';
				return;
			}

			try {
				final client = _clientFactory.getClient();
				final PaymentSummary result = await _bookingRepository.registerPayment(client, booking.reference, paymentDec);

				cabins.amountPaid = result.total;
				booking.payment = result;

				_refreshPayment();
			} catch (e) {
				print('Failed to register payment: ${e.toString()}');
				paymentError = 'Någonting gick fel när betalningen skulle registreras. Försök igen.';
			}
		} finally {
			isSaving = false;
		}
	}

	Future<Null> resetPinCode() async {
		if (isSaving)
			return;

		isSaving = true;
		resetPinCodeError = null;

		try {
			final client = _clientFactory.getClient();
			final String pinCode = await _userRepository.resetPinCode(client, booking.reference);

			if (isNotEmpty(pinCode))
				newPinCode = pinCode;
		} catch (e) {
			print('Failed to reset PIN code: ${e.toString()}');
			resetPinCodeError = 'Någonting gick fel när PIN-koden skulle återställas. Försök igen.';
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
			final tuple = await BookingSupportUtils.saveBooking(
				_clientFactory,
				_bookingRepository,
				booking,
				cabins,
				products,
				BookingResult(booking.reference, null)
			);

			// item1 is BookingResult
			// item2 is String (bookingError)
			if (null == tuple.item1) {
				bookingError = tuple.item2;
				return;
			}

			await cabins.refreshAvailability();
			await products.refreshAvailability();
			cabins.onSaved();
		} finally {
			cabins.disableAddCabins = false;
			isSaving = false;
		}
	}

	Future<Null> updateDiscount() async {
		if (isSaving)
			return;

		isSaving = true;
		paymentError = null;

		try {
			int discountInt;
			try {
				discountInt = int.parse(discount.replaceAll(',', '.').replaceAll('%', ''));
			} catch (e) {
				print('Exception parsing discount amount: ${e.toString()}');
				paymentError = 'Felaktig rabatt. Kontrollera att fältet bara innehåller siffror.';
				return;
			}

			try {
				final client = _clientFactory.getClient();
				await _bookingRepository.updateDiscount(client, booking.reference, discountInt);

				cabins.discountPercent = discountInt;
				booking.discount = discountInt;

				_refreshPayment();
			} catch (e) {
				print('Failed to update discount: ${e.toString()}');
				paymentError = 'Någonting gick fel när rabatten skulle sparas. Försök igen.';
			}
		} finally {
			isSaving = false;
		}
	}

	void _refreshPayment() {
		final remainingPrice = cabins.priceRemaining;
		if (remainingPrice.ceilToDouble() > 0.0) {
			payment = CurrencyFormatter.formatDecimalForInput(remainingPrice);
		}

		discount = booking.discount.toString();
	}
}
