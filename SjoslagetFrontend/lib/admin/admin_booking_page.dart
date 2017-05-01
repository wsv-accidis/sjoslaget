import 'dart:async';

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../booking/cabins_component.dart';
import '../client/client_factory.dart';
import '../client/booking_repository.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/booking_source.dart';
import '../model/cruise_cabin.dart';
import '../model/payment_summary.dart';
import '../util/currency_formatter.dart';
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

	@ViewChild('cabins')
	CabinsComponent cabins;

	BookingSource booking;
	bool isSaving = false;
	String payment;
	String paymentError;

	bool get canSaveCabins => !cabins.isEmpty && cabins.isValid && !isSaving;

	bool get hasLoaded => null != booking;

	bool get hasPaymentError => isNotEmpty(paymentError);

	AdminBookingPage(this._bookingRepository, this._clientFactory, this._cruiseRepository, this._routeParams);

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

	void _refreshRemainingPrice() {
		final remainingPrice = cabins.remainingPrice;
		if (remainingPrice.ceilToDouble() > 0.0) {
			payment = CurrencyFormatter.formatDecimalForInput(remainingPrice);
		}
	}
}
