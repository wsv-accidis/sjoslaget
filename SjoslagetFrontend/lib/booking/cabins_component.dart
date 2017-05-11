import 'dart:async';
import 'dart:html' show Event, HtmlElement;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';
import 'package:decimal/decimal.dart';

import 'booking_validator.dart';
import '../client/client_factory.dart';
import '../client/cruise_repository.dart';
import '../model/booking_cabin_view.dart';
import '../model/cruise_cabin.dart';
import '../util/currency_formatter.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'cabins-component',
	templateUrl: 'cabins_component.html',
	styleUrls: const ['../content/content_styles.css', 'cabins_component.css'],
	directives: const <dynamic>[materialDirectives, SpinnerWidget],
	providers: const <dynamic>[materialProviders]
)
class CabinsComponent implements OnInit {
	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final CruiseRepository _cruiseRepository;

	Map<String, int> _availability;
	List<BookingCabinView> _pendingDeleteCabins = new List<BookingCabinView>();

	Decimal amountPaid;
	List<BookingCabinView> bookingCabins = new List<BookingCabinView>();
	List<CruiseCabin> cruiseCabins;
	bool disableAddCabins;
	int discountPercent = 0;
	bool readOnly;

	String get amountPaidFormatted => CurrencyFormatter.formatDecimalAsSEK(hasPayment ? amountPaid : 0);

	Decimal get discount {
		final priceAsDec = new Decimal.fromInt(price);
		final discountAsDec = new Decimal.fromInt(discountPercent) / new Decimal.fromInt(100);
		return priceAsDec * discountAsDec;
	}

	String get discountFormatted => CurrencyFormatter.formatDecimalAsSEK(discount);

	bool get hasDiscount => discountPercent > 0;

	bool get hasPayment => null != amountPaid && amountPaid.ceilToDouble() > 0.0;

	bool get hasPrice => price > 0;

	bool get isEmpty => bookingCabins.isEmpty;

	bool get isLoaded => null != _availability && null != cruiseCabins;

	bool get isValid => bookingCabins.every((b) => b.isValid);

	int get price => bookingCabins.fold(0, (sum, b) => sum + b.price);

	String get priceFormatted => CurrencyFormatter.formatIntAsSEK(price);

	Decimal get priceRemaining => hasPayment ? priceWithDiscount - amountPaid : priceWithDiscount;

	String get priceRemainingFormatted => CurrencyFormatter.formatDecimalAsSEK(priceRemaining);

	Decimal get priceWithDiscount => new Decimal.fromInt(price) - discount;

	String get priceWithDiscountFormatted => CurrencyFormatter.formatDecimalAsSEK(priceWithDiscount);

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
		final cabin = bookingCabins[idx];
		if (cabin.isSaved)
			_pendingDeleteCabins.add(cabin);

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
		final int savedInBooking = _getNumberOfSavedCabinsInBooking(id);
		final int pendingDeletion = _getNumberOfCabinsPendingDeletion(id);
		return available - inBooking + savedInBooking + pendingDeletion;
	}

	int getNumberOfCabinsInBooking(String id) => _getCabinsInBooking(id).length;

	int getTotalAvailability(String id) {
		if (null == _availability || !_availability.containsKey(id))
			return 0;
		return _availability[id];
	}

	bool hasAvailability(String id) {
		return getAvailability(id) > 0;
	}

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			cruiseCabins = await _cruiseRepository.getActiveCruiseCabins(client);
			_availability = await _cruiseRepository.getAvailability(client);
		} catch (e) {
			print('Failed to get cabins or availability due to an exception: ' + e.toString());
			// Ignore this here - we will be stuck in the loading state until the user refreshes
		}
	}

	void onSaved() {
		_pendingDeleteCabins.clear();
		for (BookingCabinView b in bookingCabins)
			b.isSaved = true;
	}


	Future<Null> refreshAvailability() async {
		try {
			final client = _clientFactory.getClient();
			_availability = await _cruiseRepository.getAvailability(client);
		} catch (e) {
			print('Failed to refresh availability due to an exception: ' + e.toString());
			// Ignore this here, keep using old availability
		}
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

	Iterable<BookingCabinView> _getCabinsInBooking(String id) {
		return bookingCabins.where((b) => b.id == id);
	}

	CruiseCabin _getCruiseCabin(String id) {
		return cruiseCabins.firstWhere((c) => c.id == id);
	}

	int _getNumberOfSavedCabinsInBooking(String id) =>
		_getCabinsInBooking(id)
			.where((b) => b.isSaved)
			.length;

	int _getNumberOfCabinsPendingDeletion(String id) =>
		_pendingDeleteCabins
			.where((c) => c.id == id)
			.length;

}
